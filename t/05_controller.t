use strict;
use Test::More;
use MyApp::Context;

use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

my $req = HTTP::Request->new( GET => 'http://localhost/foo/bar' );
my $env = $req->to_psgi;
MyApp::Context->setup;
my $c = MyApp::Context->new();
my $guard = $c->new_request( $env );
$c->dispatch;

isa_ok $c->controller, 'MyApp::Controller::Foo';

ok $c->controller->{InitValue};
isa_ok $c->controller->{InitValue}, 'MyApp::ControllerValue';

done_testing;
