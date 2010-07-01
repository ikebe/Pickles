use inc::Module::Install;
name 'MyApp';
all_from 'lib/MyApp.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
