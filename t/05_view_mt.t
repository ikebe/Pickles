

use strict;
use Plack::Test;
use Test::More tests => 4;
use lib "./t/MyApp/lib";
use MyApp::Context;
use MyApp::View::MT;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

my $view = MyApp::View::MT->new;
isa_ok( $view, 'MyApp::View::MT' );

my $req = HTTP::Request->new( GET => 'http://localhost/foo/bar' );
my $env = $req->to_psgi;
my $c = MyApp::Context->new( $env );
my $config = $view->merge_config( $c );
is($config->{'extension'}, '.mt');

$c->stash->{'var'} = 'var1';
$c->_prepare; # set template.
my $html = $view->render( $c );
like( $html, qr/Foo/ );
like( $html, qr{<div>var1</div>});
