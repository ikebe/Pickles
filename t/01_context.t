
use strict;
use Plack::Test;
use Test::More tests => 6;
use lib "./t/MyApp/lib";
use MyApp::Context;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

my $req = HTTP::Request->new( GET => 'http://localhost/foo' );
my $env = $req->to_psgi;
my $c = MyApp::Context->new( $env );

ok $c->get('model_obj');
is ref $c->get('model_obj'), 'MyApp::Model::Test';
is $c->get('model_obj')->method1, 'MyApp::Model::Test';

is $c->uri_for('bar'), 'http://localhost/foo/bar', 'uri_for';
is $c->uri_for('/hoge'), 'http://localhost/hoge', 'uri_for';
is $c->uri_for('bar', 'baz', { q => 'Query' }), 'http://localhost/foo/bar/baz?q=Query', 'uri_for';

