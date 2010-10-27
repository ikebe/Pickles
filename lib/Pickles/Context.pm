package Pickles::Context;
use strict;
use base qw(Class::Data::Inheritable);
use Plack::Util;
use Plack::Util::Accessor qw(env stash finished controller);
use Pickles::Util;
use Class::Trigger qw(init pre_dispatch post_dispatch pre_render post_render pre_finalize post_finalize);
use String::CamelCase qw(camelize);
use Carp qw(croak);
use Try::Tiny;

__PACKAGE__->mk_classdata(__registered_components => {});
__PACKAGE__->mk_classdata(__plugins => {});
__PACKAGE__->mk_classdata(__dispatcher => undef);
__PACKAGE__->mk_classdata(__config => undef);

sub register {
    my( $class, $name, $component ) = @_;
    # register class.
    Plack::Util::load_class( $component ) unless ref $component;
    $class->__registered_components->{$name} = $component;
}

sub get {
    my( $self, $name ) = @_;
    return $self->{__components}{$name} if $self->{__components}{$name};
    my $component = $self->__registered_components->{$name};
    if ( ref($component) eq 'CODE' ) {
        $self->{__components}{$name} = $component->($self);
    }
    else {
        $self->{__components}{$name} = $component;
    }
    $self->{__components}{$name};
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

sub new {
    my( $class, $env ) = @_;
    my $self = bless { 
        controller => undef,
        stash => +{},
        env => $env,
        __components => {},
        finished => 0,
    }, $class;
    $self->call_trigger('init');
    $self;
}

sub get_routes_file {
    my $class = shift;
    $class->__config( $class->config_class->new );
    my $file = Pickles::Util::env_value('ROUTES', $class->appname );
    if (! $file) {
        $file = $class->config->path_to( 'etc/routes.pl' );
    }
    return $file;
}

sub setup {
    my $class = shift;
    my $file = $class->get_routes_file();
    $class->__dispatcher( $class->dispatcher_class->new( file => $file ) );

    # preload controller classes
    my $routes = $class->__dispatcher->router->{routes};
    if ($routes) {
        my %seen;
        foreach my $route (@$routes) {
            my $dest = $route->dest;
            my $controller = $dest->{controller};
            if (! $controller) {
                warn "No controller specified for path " . $route->pattern;
            }

            next if $seen{ $controller }++;
            Plack::Util::load_class( "Controller::" . camelize($controller), $class->appname );
        }
    }
}

sub config {
    my $class = shift;
    $class->setup unless defined $class->__config;
    $class->__config;
}

sub appname {
    my $self = shift;
    my $pkg = ref $self ? ref $self : $self;
    $pkg =~ s/::Context$//;
    $pkg;
}

sub request {
    my $self = shift;
    $self->{_request} ||= do {
        my $class = $self->request_class;
        $class->new( $self->env );
    };
}
sub req { shift->request(@_); }

sub response {
    my $self = shift;
    $self->{_response} ||= do {
        my $class = $self->response_class;
        $class->new( 200 );
    };
}
sub res { shift->response(@_); }

sub match {
    my $self = shift;
    my $dispatcher = $self->__dispatcher;
    $self->{_match} ||= $dispatcher->match( $self->req );
}

sub render {
    my( $self, $view_class ) = @_;
    if ( $view_class ) {
        $view_class = Plack::Util::load_class( $view_class, $self->appname );
    }
    else {
        $view_class = $self->view_class;
    }

    my $view;
    try { $view = $self->get( "_$view_class" ) };
    if (! $view) {
        $self->register( "_$view_class" => ($view = $view_class->new));
    }
    $self->res->content_type( $view->content_type );
    my $body = $view->render( $self );
    $self->res->body( $body );
    $self->finished(1);
}

sub dispatch {
    my $self = shift;
    $self->_prepare;
    my $controller_class = $self->controller_class;
    my $action = $self->action;
    unless ( $controller_class && defined $action ) {
        return $self->handle_not_found;
    }
    my $controller;
    try { $controller = $self->get( "_$controller_class" ) };
    if (! $controller) {
        $self->register( "_$controller_class" => ($controller = $controller_class->new));
    }

    $self->{controller} = $controller;
    try {
        $self->call_trigger('pre_dispatch');
        $controller->execute( $action, $self );
        $self->call_trigger('post_dispatch');
        unless ( $self->finished ) {
            $self->call_trigger('pre_render');
            $self->render;
            $self->call_trigger('post_render');
        }
    }
    catch {
        croak $_ unless /^PICKLES_EXCEPTION_ABORT/
    };
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
    my $req = $self->req;
    my $uri = $req->uri->clone;
    my $params =
        ( scalar @args && ref $args[$#args] eq 'HASH' ? pop @args : {} );
    if ( $args[0] =~ m{^/} ) {
        $uri->path( join '/', @args );
    }
    else {
        my @path_segments = grep { $_ } map {
            split /\//, $_
        } ($uri->path, @args);
        $uri->path_segments( @path_segments );
    }
    $uri->query_form( $params );
    $uri;
}

sub handle_not_found {
    my $self = shift;
    $self->res->status( 404 );
    $self->not_found;
    $self->finished(1);
    $self->res->finalize;
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

sub request_class {
    Plack::Util::load_class( 'Pickles::Request' );
}

sub response_class {
    Plack::Util::load_class( 'Pickles::Response' );
}

sub dispatcher_class {
    my $self = shift;
    Plack::Util::load_class( 'Dispatcher', $self->appname );
}

sub config_class {
    my $self = shift;
    Plack::Util::load_class( 'Config', $self->appname );
}

sub view_class {
    my $self = shift;
    Plack::Util::load_class( 'View', $self->appname );
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

=head2 $c->request, $c->req

returns a L<Pickles::Request> object.

=head2 $c->response, $c->res

returns a L<Pickles::Response> object.

=head2 $c->uri_for( @path, \%query );

construct absolute uri of the @path.
\%query values are treat as QUERY_STRING.

=head1 AUTHOR

Tomohiro Ikebe E<lt>ikebe {at} livedoor.jpE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
