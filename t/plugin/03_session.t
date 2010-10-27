
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
$ENV{'MYAPP_ENV'} = 'session';
MyApp::Context->load_plugins(qw(Session));
my $cookie;
my $app = MyApp->handler;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/count' );
        my $res = $cb->( $req );
        is $res->code, '200';
        like $res->content, qr/COUNT:1/;
        like $res->header('Set-Cookie'), qr/^http_session_sid=/;
        $cookie = (split(/;/, $res->header('Set-Cookie')))[0];
    } ;

test_psgi
    app => $app,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/count' );
        $req->header('Cookie' => $cookie);
        my $res = $cb->( $req );
        is $res->code, '200';
        like $res->content, qr/COUNT:2/;
    } ;


