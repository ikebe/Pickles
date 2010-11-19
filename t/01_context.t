
use strict;
use Plack::Test;
use Test::More;
use MyApp::Context;
use MyApp;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

my $req = HTTP::Request->new( GET => 'http://localhost/foo' );
my $env = $req->to_psgi;

my $c = MyApp->create_context( env => $env );

ok $c->get('model_obj');
is ref $c->get('model_obj'), 'MyApp::Model::Test';
is $c->get('model_obj')->method1, 'MyApp::Model::Test';

# uri_for.
is $c->uri_for('/'), 'http://localhost/', 'uri_for';
is $c->uri_for('bar'), 'http://localhost/foo/bar', 'uri_for';
is $c->uri_for('/hoge'), 'http://localhost/hoge', 'uri_for';
is $c->uri_for('bar', 'baz', { q => 'Query' }), 'http://localhost/foo/bar/baz?q=Query', 'uri_for';

is $c->appname, "MyApp";

done_testing();
