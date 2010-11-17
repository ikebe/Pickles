
use strict;
use Plack::Test;
use lib "./t/MyApp/lib";
use Test::More tests => 3;
use MyApp;
use MyApp::Context;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use MyApp;
use Encode;

# q=ライブドア
my $req = HTTP::Request->new( GET => 'http://localhost/foo?q=%E3%83%A9%E3%82%A4%E3%83%96%E3%83%89%E3%82%A2' );
my $env = $req->to_psgi;
MyApp::Context->load_plugins(qw(Encode));
my $c = MyApp->create_context( env => $env );
$c->dispatch;

ok(utf8::is_utf8($c->req->param('q')));

ok(!utf8::is_utf8($c->res->body));
like($c->res->body, qr/ライブドア/);
