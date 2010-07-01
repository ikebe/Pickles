use inc::Module::Install;
name 'Pickles';
all_from 'lib/Pickles.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
requires 'Plack' => '0.99';
requires 'Class::Data::Inheritable' => 0;
requires 'Path::Router' => '0.06';

install_script 'script/pickles-setup';

use_test_base;
auto_include;
WriteAll;
