package Pickles::Plugin::AntiCSRF;
use strict;
use String::Random qw(random_regex);

sub install {
    my( $class, $pkg ) = @_;
    my $token_name = $pkg->config->{'Plugin::AntiCSRF'}->{token_name} || '_token';
    my $token_length = $pkg->config->{'Plugin::AntiCSRF'}->{token_length} || 8;
    $pkg->add_trigger( post_render => sub {
        my $c = shift;
        my $body = $c->res->body;
        my $token = ($c->req->session->{$token_name} ||= random_regex("[a-zA-Z0-9_]{$token_length}"));
        $body =~ s{</form>}{<input type="hidden" name="$token_name" value="$token" /></form>}ig;
        $c->res->body( $body );
    } );
    $pkg->add_trigger( pre_dispatch => sub {
        my $c = shift;
        if ( $c->req->method eq 'POST' && !$c->stash->{skip_csrf_check} ) {
            my $token = $c->req->param( $token_name );
            unless ( $token && $token eq $c->req->session->{$token_name} ) {
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
