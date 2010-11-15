package Pickles::Plugin::AntiCSRF;
use strict;
use String::Random qw(random_regex);
use Carp ();

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_trigger( post_render => sub {
        my $c = shift;
        unless ( $c->has_plugin('Session') ) {
            Carp::croak('You MUST load Pickles::Plugin::Session!');
        }

        if ($c->res->content_type !~ /html$/i) {
            # no need to waste time parsing the body if this is not
            # an HTML document
            return;
        }
        my $config = $c->config->{'Plugin::AntiCSRF'};
        my $token_name = $config->{token_name} || '_token';
        my $length = $config->{token_length} || 8;

        my $body = $c->res->body;
        my $token = 
            $c->session->get( $token_name ) || random_regex("[a-zA-Z0-9_]{$length}");
        $body =~ s{</form>}{<input type="hidden" name="$token_name" value="$token" /></form>}ig;
        $c->res->body( $body );
        $c->session->set( $token_name => $token );
    } );
    $pkg->add_trigger( pre_dispatch => sub {
        my $c = shift;
        my $token_name = 
            $c->config->{'Plugin::AntiCSRF'}->{token_name} || '_token';
        if ( $c->req->method eq 'POST' && !$c->stash->{skip_csrf_check} ) {
            my $req_val = $c->req->param( $token_name );
            my $session_val = $c->session->get( $token_name );
            unless ( $req_val && $session_val && ($req_val eq $session_val) ) {
                $c->detect_csrf;
            }
        }
    } );
    unless ( $pkg->can('detect_csrf') ) {
        $pkg->add_method('detect_csrf' => sub {
            my $c = shift;
            $c->res->status( 403 );
            $c->res->body( 'Forbidden' );
            $c->abort;
        });
    }
}

1;

__END__
