use inc::Module::Install;
name 'Pickles';
all_from 'lib/Pickles.pm';

tests 't/*.t t/plugin/*.t';
#author_tests 'xt';

build_requires 'Test::More';
requires 'Plack' => '0.99';
requires 'Module::Setup' => '0.09';
requires 'Class::Data::Inheritable';
requires 'Router::Simple';
requires 'String::CamelCase';
requires 'UNIVERSAL::require';
requires 'Class::Trigger';
requires 'Text::MicroTemplate::Extended';

install_script 'script/pickles-setup';

auto_include;
WriteAll;
