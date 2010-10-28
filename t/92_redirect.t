
use strict;
use Plack::Test;
use Test::More tests => 10;
use MyApp;
use Plack::App::URLMap;
# 

my $app = MyApp->handler;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/redirect' );
        my $res = $cb->( $req );
        is $res->code, '302';
        is $res->headers->header('Location'), 'http://localhost/';

    } ;

# remove QUERY_STRING.
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/redirect?foo=bar' );
        my $res = $cb->( $req );
        is $res->code, '302';
        is $res->headers->header('Location'), 'http://localhost/';

    } ;

# works with P::A::URLMap
my $urlmap = Plack::App::URLMap->new;
$urlmap->map('/x' => $app);
test_psgi
    app => $urlmap->to_app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/x/redirect' );
        my $res = $cb->( $req );
        is $res->code, '302';
        is $res->headers->header('Location'), 'http://localhost/x/';

    } ;


test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/redirect2?foo=bar' );
        my $res = $cb->( $req );
        is $res->code, '302';
        is $res->headers->header('Location'), 'http://search.cpan.org/';

    } ;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/redirect_and_abort' );
        my $res = $cb->( $req );
        is $res->code, '302';
        is $res->headers->header('Location'), 'http://www.livedoor.com/';

    } ;


