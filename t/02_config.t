
use strict;
use Plack::Test;
use Test::More tests => 17;
use lib "./t/MyApp/lib";
use MyApp::Config;
use Scalar::Util qw(refaddr);

{
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
}

$MyApp::Config::_instance = undef;
{
    # Check that both MYAPP_CONFIG and MYAPP_ENV are respected
    use Cwd ();
    use File::Spec;
    $ENV{'MYAPP_CONFIG'} = File::Spec->catfile(Cwd::cwd(), 't', '02_config_foo.pl');
    $ENV{'MYAPP_ENV'} = 'test';

    my ($config, $buffer);
    {
        local *STDERR;
        open STDERR, '>', \$buffer;
        $config = MyApp::Config->instance;
    }

    isa_ok( $config, 'MyApp::Config' );
    is @{$config->{__FILES}}, 3;
}

$MyApp::Config::_instance = undef;
{
    $ENV{'MYAPP_CONFIG'} = File::Spec->catfile(Cwd::cwd(), 't', '02_config_bar.pl');
    $ENV{'MYAPP_ENV'} = 'test';

    my ($config, $buffer);
    {
        local *STDERR;
        open STDERR, '>', \$buffer;
        $config = MyApp::Config->instance;
    }
    if (ok $buffer) {
        like $buffer, qr/02_config_bar\.pl: Bogus error/;
        like $buffer, qr/02_config_bar_test\.pl: Bogus error/;
    }

    isa_ok( $config, 'MyApp::Config' );
    is @{$config->{__FILES}}, 3;
}
