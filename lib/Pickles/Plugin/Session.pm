package Pickles::Plugin::Session;
use strict;
use UNIVERSAL::require;

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_trigger( init => sub {
        my $c = shift;
        if ( $c->env->{'psgix.session'} ) {
            Plack::Session->require;
            $c->stash->{'_session'} = Plack::Session->new( $c->env );
        }
        else {
            HTTP::Session->require;
            my $config = $c->config->{'Plugin::Session'};
            my $session= HTTP::Session->new( %{$config}, request => $c->req );
            $c->stash->{'_session'} = $session;
        }
    });
    $pkg->add_trigger( pre_finalize => sub {
        my $c = shift;
        unless ( $c->env->{'psgix.session'} ) {
            my $session = $c->session;
            $session->response_filter( $c->res );
        }
    });
    $pkg->add_method( session => sub {
        my $c = shift;
        $c->stash->{'_session'};
    });
}

1;

__END__
