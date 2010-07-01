
use strict;
use Plack::Test;
use Test::More tests => 3;
use lib "./t/MyApp/lib";
use MyApp::Config;

my $config = MyApp::Config->instance;

isa_ok( $config, 'MyApp::Config' );
like $config->{__files}->[0], qr/config\.pl$/;
is $config->{TestValue}, '1';

