
use strict;
use Plack::Test;
use Test::More tests => 1;
use lib "./t/MyApp/lib";
use MyApp::Context;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

my $req = HTTP::Request->new( GET => 'http://localhost/' );
my $env = $req->to_psgi;
MyApp::Context->load_plugins(qw(+MyApp::Plugin::Test));
my $c = MyApp::Context->new( $env );

is $c->test_func, 'test_func', 'call plugin method';


