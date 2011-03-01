package Pickles::Dispatcher;
use strict;
use Carp ();
use Cwd();
use Plack::Util;
use Router::Simple;
use String::CamelCase qw(camelize);

sub new {
    my ($class, %args) = @_;

    my $file = $args{file} || Carp::croak("No file given to $class->new");
    my $pkg = $file;
    $pkg =~ s/([^A-Za-z0-9_])/sprintf("_%2x", unpack("C", $1))/eg;

    if (! File::Spec->file_name_is_absolute( $file ) ) {
        $file = Cwd::abs_path( $file );
    }
    my $fqname = sprintf '%s::%s', $class, $pkg;
    my $router_pkg = sprintf <<'SANDBOX', $fqname;
package %s;
use Router::Simple::Declare;
{
    delete $INC{$file};
    my $conf = require $file or die $!;
    $conf;
}
SANDBOX
    my $router = eval $router_pkg;
    if (! eval { $router->isa( 'Router::Simple' ) } || $@ ) {
        Carp::croak("file $args{file} returned something other than Router::Simple");
    }
    bless { router => $router }, $class;
}

sub router {
    my $self = shift;
    $self->{router};
}

sub match {
    my( $self, $req ) = @_;
    my $match = $self->router->match( $req->env );
    my %args;
    for my $key( keys %{$match} ) {
        next if $key =~ m{^(controller|action)$};
        $args{$key} = delete $match->{$key};
    }
    $match->{args} = \%args;
    $match;
}

sub load_controllers {
    my( $self, $prefix ) = @_;
    my $routes = $self->router->{routes};
    if ($routes) {
        my %seen;
        foreach my $route (@$routes) {
            my $dest = $route->dest;
            my $controller = $dest->{controller};
            if (! $controller) {
                warn "No controller specified for path " . $route->pattern;
            }
            next if $seen{ $controller }++;
            Plack::Util::load_class( "Controller::" . camelize($controller), $prefix );
        }
    }
    1;
}

1;

__END__

=head1 NAME

Pickles::Dispatcher - Dispatcher Object

=head1 SYNOPSIS

    # in MyApp::Controller::Foo
    package MyApp::Controller::Foo;
    use base qw(Pickles::Controller);

    sub index {
        my ($self, $c) = @_;
        ....
    }

    # etc/routes.pl
    # Router::Simple::Declare is implicitly imported into the current
    # scope, so you can use it's methods right away
    router {
        connect '/' =>
            { controller => 'Foo', action => 'index' }
    };

=head1 DESCRIPTION

Pickles::Dispatcher uses Router::Simple to route your requests.
Unlike frameworks like Catalyst, the mapping between URI and Controller
actions are separated out to an external file (etc/routes.pl by default)

=head1 METHODS

If you are an application developer, you should not need to touch
these directly.

=head2 new

=head2 router

=head2 match

=cut
