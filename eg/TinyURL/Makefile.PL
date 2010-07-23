use inc::Module::Install;
name 'TinyURL';
all_from 'lib/TinyURL.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
