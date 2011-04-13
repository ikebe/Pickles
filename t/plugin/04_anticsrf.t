
use strict;
use Plack::Test;
use lib "./t/MyApp/lib";
use Test::More;
use MyApp::Context;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use MyApp;

my $load_error = 0;
foreach my $module ( qw( HTTP::Session String::Random ) ) {
    eval "require $module";
    if ( $@ ) {
        plan skip_all => "$module is not installed";
        $load_error++;
        last;
    }
}
plan tests => 15;

$ENV{'MYAPP_ENV'} = 'session';
MyApp::Context->load_plugins(qw(Session AntiCSRF FillInForm));
my $app = MyApp->handler;
# fail
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( POST => 'http://localhost/form' );
        my $res = $cb->( $req );
        is $res->code, '403';
    } ;

my $token;
my $cookie;
# get token
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/form' );
        my $res = $cb->( $req );
        ($token) = $res->content =~ qr/name="_token" value="(.*?)"/;
        like $res->header('Set-Cookie'), qr/^http_session_sid=/;
        $cookie = (split(/;/, $res->header('Set-Cookie')))[0];
        ok( $token, 'got token' );
        is $res->code, '200';
    } ;

# success
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $content = "_token=${token}";
        my $req = 
            HTTP::Request->new( POST => 'http://localhost/form' );
        $req->content( $content );
        $req->content_length( length($content) );
        $req->content_type( 'application/x-www-form-urlencoded' );
        $req->header('Cookie' => $cookie);
        my $res = $cb->( $req );
        is $res->code, '200';
    } ;

# skip
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( POST => 'http://localhost/form_skip' );
        my $res = $cb->( $req );
        is $res->code, '200';
    } ;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( POST => 'http://localhost/api' );
        my $res = $cb->( $req );
        is $res->code, '200';
    } ;

# fill token
test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/form2' );
        my $res = $cb->( $req );
        ($token) = $res->content =~ qr/name="_token" value="(.*?)"/;
        ok( $token, 'got token form2' );
        is $res->code, '200';
    } ;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/form3' );
        my $res = $cb->( $req );
        ($token) = $res->content =~ qr/name="_token" value="(.*?)"/;
        ok( $token, 'got token form3' );
        is $res->code, '200';
    } ;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/form_get' );
        my $res = $cb->( $req );
        ($token) = $res->content =~ qr/name="_token" value="(.*?)"/;
        ok( !$token, 'no got token form_get' );
        is $res->code, '200';
    } ;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/form_get2' );
        my $res = $cb->( $req );
        ($token) = $res->content =~ qr/name="_token" value="(.*?)"/;
        ok( !$token, 'no got token form_get2' );
        is $res->code, '200';
    } ;
