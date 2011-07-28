package Pickles::Context;
use strict;
use base qw(Class::Data::Inheritable);
use Plack::Util;
use Plack::Util::Accessor qw(env stash finished controller config dispatcher container);
use Class::Trigger qw(init pre_dispatch post_dispatch pre_render post_render pre_finalize post_finalize);
use String::CamelCase qw(camelize);
use Carp ();
use Try::Tiny;
use Scalar::Util qw(blessed);

use Pickles::Util;
use Pickles::Controller;

__PACKAGE__->mk_classdata(__components => {});
__PACKAGE__->mk_classdata(__plugins => {});

__PACKAGE__->mk_classdata(request_class => '+Pickles::Request');
__PACKAGE__->mk_classdata(response_class => '+Pickles::Response');
__PACKAGE__->mk_classdata(view_class => 'View');

# shortcut for container.
sub register {
    my $self = shift;
    Carp::croak( $self. '->register is deprecated. Use container profile file instead. See Pickles::Container for detail.' ) unless blessed( $self );
    $self->container->register( @_ );
}

sub get {
    my $self = shift;
    $self->container->get( @_ );
}

sub load_plugins {
    my( $class, @plugins ) = @_;
    for my $plugin( @plugins ) {
        my $plugin_class = Plack::Util::load_class( $plugin, 'Pickles::Plugin' );
        $plugin_class->install( $class );
        $class->__plugins->{$plugin} = $plugin_class;
    }
}

sub plugins {
    my $class = shift;
    values %{$class->__plugins};
}

sub has_plugin {
    my( $pkg, $name ) = @_;
    $pkg->__plugins->{$name};
}

sub add_method {
    my( $pkg, $method, $code ) = @_;
    {
        no strict 'refs';
        *{"$pkg\::$method"} = $code;
    }
}

sub load {
    my( $self, $component ) = @_;
    my $loaded = 
        Plack::Util::load_class( $self->$component(), $self->appname );
    $loaded;
}

sub new {
    my $class = shift;
    my %args;
    if ( @_ == 1 && ref $_[0] eq 'HASH' ) {
        $args{env} = $_[0];
    }
    else {
        %args = @_;
    }
    Carp::croak(q{$env is required}) unless $args{env};
    my $self = bless { 
        controller => undef,
        stash => +{},
        finished => 0,
        %args,
    }, $class;
    $self->call_trigger('init');
    $self;
}

sub appname {
    my $self = shift;
    my $class = ref $self ? ref $self : $self;
    Pickles::Util::appname( $class );
}

sub request {
    my $self = shift;
    $self->{_request} ||= do {
        my $class = $self->load('request_class');
        $class->new( $self->env );
    };
}
sub req { shift->request(@_); }

sub response {
    my $self = shift;
    $self->{_response} ||= do {
        my $class = $self->load('response_class');
        $class->new( 200 );
    };
}
sub res { shift->response(@_); }

sub match {
    my $self = shift;
    my $dispatcher = $self->dispatcher;
    $self->{_match} ||= $dispatcher->match( $self->req );
}

sub render {
    my( $self, $view_class ) = @_;
    if ( $view_class ) {
        $view_class = Plack::Util::load_class( $view_class, $self->appname );
    }
    else {
        $view_class = $self->load('view_class');
    }
    my $view;
    try { $view = $self->__components->{"$view_class"} };
    if (! $view) {
        $self->__components->{"$view_class"} = ($view = $view_class->new);
    }
    $self->res->content_type( $view->content_type );
    my $body = $view->render( $self );
    $self->res->body( $body );
    $self->finished(1);
}

sub dispatch {
    my $self = shift;

    my $guard = $self->container->new_scope;

    $self->_prepare;
    my $controller_class = $self->controller_class;
    my $action = $self->action;
    unless ( $controller_class && $self->validate_action( $action ) ) {
        $self->handle_not_found;
        return $self->finalize;
    }
    my $controller;
    try { $controller = $self->__components->{"$controller_class"} };
    if (! $controller) {
        $self->__components->{"$controller_class"} = ($controller = $controller_class->new);
    }
    $controller->init( $self );
    $self->controller( $controller );

    try {
        $self->call_trigger('pre_dispatch');
        $controller->execute( $action, $self );
        $self->call_trigger('post_dispatch');
    }
    catch {
        unless (/^PICKLES_EXCEPTION_ABORT/) {
            local $SIG{__DIE__} = 'DEFAULT';
            die $_;
        }
    };
    unless ( $self->finished ) {
        $self->call_trigger('pre_render');
        $self->render;
        $self->call_trigger('post_render');
    }
    return $self->finalize;
}

sub abort { die 'PICKLES_EXCEPTION_ABORT'; }

sub _prepare {
    my $self = shift;
    my $path = $self->req->path_info;
    $path .= 'index' if $path =~ m{/$};
    $path =~ s{^/}{};
    $self->stash->{'VIEW_TEMPLATE'} = $path;
}

sub finalize {
    my $self = shift;
    $self->call_trigger('pre_finalize');
    my $result = $self->res->finalize;
    $self->call_trigger('post_finalize');
    $result;
}

sub uri_for {
    my( $self, @args ) = @_;
    # Plack::App::URLMap
    my $req = $self->req;
    my $uri = $req->base;
    my $params =
        ( scalar @args && ref $args[$#args] eq 'HASH' ? pop @args : {} );
    my @path = split '/', $uri->path;
    unless ( $args[0] =~ m{^/} ) {
        push @path, split( '/', $self->req->path_info );
    }
    push @path, @args;
    my $path = join '/', @path;
    $path =~ s|/{2,}|/|g; # xx////xx  -> xx/xx
    $uri->path( $path );
    $uri->query_form( $params );
    $uri;
}

sub handle_not_found {
    my $self = shift;
    $self->res->status( 404 );
    $self->not_found;
    $self->finished(1);
}

sub not_found {
    my $self = shift;
    $self->res->content_type('text/html');
    $self->res->body(<<'HTML');
<html>
<head>
<title>404</title>
</head>
<body>
<h1>404 File Not Found</h1>
</body>
</html>
HTML
}

sub redirect {
    my( $self, $url, $code ) = @_;
    $code ||= 302;
    $self->res->status( $code );
    $url = ($url =~ m{^https?://}) ? $url : $self->uri_for( $url );
    $self->res->headers->header(Location => $url);
    $self->finished(1);
}

sub controller_class {
    my $self = shift;
    my $match = $self->match;
    my $controller = $match->{controller};
    return unless $controller;
    my $class = Plack::Util::load_class(
        'Controller::'. camelize( $controller ), 
        $self->appname
    );
    $class;
}

my %_reserved_actions = 
    map { $_ => 1 }
    grep { defined &{"Pickles::Controller::$_"} } 
    keys %{Pickles::Controller::};

sub validate_action {
    my( $self, $action ) = @_;
    return unless defined $action;
    return if $_reserved_actions{$action};
    return $action =~ m{^[a-z][a-zA-Z0-9_]*$};
}

sub action {
    my $self = shift;
    my $match = $self->match;
    $match->{action};
}

sub args {
    my $self = shift;
    my $match = $self->match;
    $match->{args};
}

1;

__END__

=head1 NAME

Pickles::Context - Pickles context class.

=head1 SYNOPSIS

  package MyApp::Context;
  
  use strict;
  use warnings;
  use parent 'Pickles::Context';
  __PACKAGE__->load_plugins(qw(Encode));
   
  1;
  
  __END__

=head1 METHODS

=head2 $c->appname

returns a application name.

=head2 $c->request, $c->req

returns a request object.

=head2 $c->response, $c->res

returns a response object.

=head2 $c->config

returns config object.

=head2 $c->render( [ $view_class ] );

render content with specified view class.
if $view_class is omitted, $c->view_class is used as default.

=head2 $c->uri_for( @path, \%query );

construct absolute uri of the @path.
\%query values are treat as QUERY_STRING.

=head2 $c->redirect( $url, [ $code ] );

redirect to the $url. default $code is 302.
if $url is not absolute, the value is passed to $c->uri_for

=head2 $c->abort

abort next operation and goto finalize phase.

=head2 MyApp::Context->load_plugins(...);

load plugins. Omit the C<Pickles::Plugin::> prefix from the name.

=head2 $c->register( $name, $initializer );

Register a object. This method is delegated to C<Container>.
see L<Pickles::Container> for details.

=head2 $c->get( $name );

get the registerred object referred by the given $name.
This method is delegated to C<Container>.

=head1 CLASS VARIABLES

The following class variables specify component classes.
Omit the $c->appname prefix from the class name.

    # MyApp::View
    MyApp::Context->view_class('View');

    # MyApp::View::TT
    MyApp::Context->view_class('View::TT');

if you want to use fully qualified class name, use plus sign prefix.

    # Foo::View
    MyApp::Context->view_class('+Foo::View');

=head2 MyApp::Context->request_class

default value is C<+Pickles::Request>

=head2 MyApp::Context->response_class

default value is C<+Pickles::Response>

=head2 MyApp::Context->view_class

default value is C<View>

=head1 AUTHOR

Tomohiro Ikebe E<lt>ikebe {at} livedoor.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
