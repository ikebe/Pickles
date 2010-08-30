

use strict;
use Plack::Test;
use Test::More tests => 5;
#use Test::More 'no_plan';
use lib "./t/MyApp/lib";
use MyApp::Context;
use MyApp::View;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

my $view = MyApp::View->new;
isa_ok( $view, 'MyApp::View' );

my $req = HTTP::Request->new( GET => 'http://localhost/foo' );
my $env = $req->to_psgi;
my $c = MyApp::Context->new( $env );
my $config = $view->merge_config( $c );

is($config->{'TEMPLATE_EXTENSION'}, '.html');
is($config->{'VARIABLES'}{'foo'}, 'bar');

$c->stash->{'var'} = 'var1';
$c->_prepare; # set template.
my $html = $view->render( $c );
like( $html, qr/Foo/ );
like( $html, qr{<div>var1</div>});
