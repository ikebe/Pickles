# Jump around hoops and let people who download this code via
# the git repo know what M::I modules you need to install to
# build this module
BEGIN {
    my @mi_mods = qw(
        inc::Module::Install;
        Module::Install::AuthorTests;
        Module::Install::TestTarget;
    );
    my @unavailable;
    foreach my $mod ( @mi_mods ) {
        eval qq{ require $mod } or 
            push @unavailable, $mod;
    }

    if (@unavailable) {
        print STDERR <<EOM;
    
**** Missing Developer Tools! ****

Whoa there, you don't have the required modules to run this Makefile.PL!
This probably means you cloned the repository from github (if you
encounter this from a tarball uploaded to CPAN, it's a bug, so please
report it).

If you are running from a cloned git repository, install the following
modules first:

EOM
        print STDERR "    * $_\n" for @unavailable;
        print STDERR <<EOM;

use cpanm or cpan to install these via

    cpanm @unavailable

and try again

EOM
        exit 0;
    }
    Module::Install->import;
}



use inc::Module::Install;
name 'Pickles';
all_from 'lib/Pickles.pm';

tests 't/*.t t/plugin/*.t';
author_tests 'xt';

build_requires 'Test::More';
requires 'Plack' => '0.99';
requires 'Module::Setup' => '0.09';
requires 'Class::Data::Inheritable';
requires 'Router::Simple';
requires 'String::CamelCase';
requires 'Class::Trigger';

requires 'Text::Xslate';
requires 'Text::Xslate::Bridge::TT2Like';

install_script 'script/pickles-setup';

auto_include;

default_test_target 
    includes => "t/MyApp/lib"
;

WriteAll;
