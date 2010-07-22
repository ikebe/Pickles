package MyApp::View;

use strict;
use warnings;
use parent 'Pickles::View::TT';

__PACKAGE__->config({
    TEMPLATE_EXTENSION => '.tmpl',
    VARIABLES => {
        foo => 'bar',
    },
});

1;

__END__

