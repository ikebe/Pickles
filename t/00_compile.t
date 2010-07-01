use strict;
use Test::More tests => 9;

BEGIN { 
    use_ok 'Pickles';
    use_ok 'Pickles::WebApp';
    use_ok 'Pickles::Util';
    use_ok 'Pickles::Request';
    use_ok 'Pickles::Response';
    use_ok 'Pickles::Context';
    use_ok 'Pickles::Config';
    use_ok 'Pickles::View';
    use_ok 'Pickles::Controller';
}
