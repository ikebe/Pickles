use inc::Module::Install;
name 'Pickles';
all_from 'lib/Pickles.pm';

tests 't/*.t';
#author_tests 'xt';

build_requires 'Test::More';
requires 'Plack' => '0.99';
requires 'Module::Setup' => '0.09';
requires 'Class::Data::Inheritable';
requires 'Router::Simple';
requires 'String::CamelCase';
requires 'UNIVERSAL::require';

install_script 'script/pickles-setup';

#use_test_base;
auto_include;
WriteAll;
