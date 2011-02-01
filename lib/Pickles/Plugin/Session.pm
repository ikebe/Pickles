package Pickles::Plugin::Session;
use strict;
my $session_key = 'pickles.session';
my ($plack_session_loaded, $http_session_loaded);

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_trigger( init => sub {
        my $c = shift;
        if ( $c->env->{'psgix.session'} ) {
            if ( ! $plack_session_loaded) {
                eval { require Plack::Session };
                die if $@;
                $plack_session_loaded++;
            }
            $c->env->{ $session_key } = Plack::Session->new( $c->env );
        }
        else {
            if ( ! $http_session_loaded ) {
                eval { require HTTP::Session };
                die if $@;
                $http_session_loaded++;
            }
            my $config = $c->config->{'Plugin::Session'};
            my $session= HTTP::Session->new( %{$config}, request => $c->req );
            $c->env->{ $session_key } = $session;
        }
    });
    $pkg->add_trigger( pre_finalize => sub {
        my $c = shift;
        unless ( $c->env->{'psgix.session'} ) {
            my $session = $c->session;
            $session->response_filter( $c->res );
        }
    });
    $pkg->add_trigger( post_finalize => sub {
        my $c = shift;
        delete $c->env->{ $session_key };
    } );
    $pkg->add_method( session => sub {
        my $c = shift;
        $c->env->{ $session_key };
    });
}

1;

__END__
