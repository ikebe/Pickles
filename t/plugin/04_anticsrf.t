
use strict;
use Plack::Test;
use lib "./t/MyApp/lib";
use Test::More;
use MyApp::Context;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use MyApp;

eval { require HTTP::Session };
if ( $@ ) {
    plan skip_all => "HTTP::Session is not installed";
}
else {
    plan tests => 5;
}


MyApp::Context->load_plugins(qw(Session AntiCSRF FillInForm));

# fail
test_psgi
    app => MyApp->handler,
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
    app => MyApp->handler,
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
    app => MyApp->handler,
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




