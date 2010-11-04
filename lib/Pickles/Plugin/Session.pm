package Pickles::Plugin::Session;
use strict;

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_trigger( init => sub {
        my $c = shift;
        if ( $c->env->{'psgix.session'} ) {
            eval { require Plack::Session };
            die if $@;
            $c->stash->{'_session'} = Plack::Session->new( $c->env );
        }
        else {
            eval { require HTTP::Session };
            die if $@;
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
