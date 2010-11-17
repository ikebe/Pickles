
use strict;
use Plack::Test;
use lib "./t/MyApp/lib";
use Test::More;
use MyApp::Context;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use MyApp;

eval { require HTML::FillInForm };
if ( $@ ) {
    plan skip_all => "HTML::FillInForm is not installed";
}
else {
    plan tests => 2;
}

$Plack::Test::Impl = "Server";

MyApp::Context->load_plugins(qw(Encode FillInForm));

test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( POST => 'http://localhost/form' );
        $req->header('Content-Type' => 'application/x-www-form-urlencoded');
        # text=ライブドア
        $req->content( 'text=%E3%83%A9%E3%82%A4%E3%83%96%E3%83%89%E3%82%A2' );
        my $res = $cb->( $req );
        is $res->code, '200';
        like $res->content, qr/value="ライブドア"/;
    } ;

