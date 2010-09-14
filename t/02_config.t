
use strict;
use Plack::Test;
use Test::More tests => 6;
use lib "./t/MyApp/lib";
use MyApp::Config;
use Scalar::Util qw(refaddr);

my $config1 = MyApp::Config->instance;

isa_ok( $config1, 'MyApp::Config' );
like $config1->{__FILES}->[0], qr/config\.pl$/;
is $config1->{TestValue}, '1';
is $config1->get('TestValue'), '1';

is $config1->get('UndefinedValue', 2), '2';

# singleton.
my $config2 = MyApp::Config->instance;
is refaddr($config1), refaddr($config2), 'singleton';

