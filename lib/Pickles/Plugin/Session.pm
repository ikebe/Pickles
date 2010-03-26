package Pickles::Plugin::Session;
use strict;
use base qw(Pickles::Plugin);
use Plack::Middleware::Session;

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_method( 'session', sub {
        my $c = shift;
        $c->req->env->{'psgix.session'};
    } );
}

sub wrap_app {
    my( $class, $app, $config ) = @_;
    $config = $config->{'Plugin::Session'} || {};
    Plack::Middleware::Session->wrap( $app, $config );
}

1;

__END__
