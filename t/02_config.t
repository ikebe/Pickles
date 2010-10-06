
use strict;
use Plack::Test;
use Test::More tests => 10;
use lib "./t/MyApp/lib";
use MyApp::Config;
use Scalar::Util qw(refaddr);

$ENV{'MYAPP_ENV'} = 'test';
my $config = MyApp::Config->instance;

isa_ok( $config, 'MyApp::Config' );
is @{$config->{__FILES}}, 2;
like $config->{__FILES}->[0], qr/config\.pl$/;

is $config->{Value}, '1';
is $config->get('Value'), '1';

is $config->{TestValue}, '2';
is $config->get('TestValue'), '2';

is $config->get('UndefinedValue', 2), '2';

# __path_to()
like $config->get('tmp_dir'), qr{^/};

# singleton.
my $config2 = MyApp::Config->instance;
is refaddr($config), refaddr($config2), 'singleton';


