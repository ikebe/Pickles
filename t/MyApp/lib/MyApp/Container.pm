package MyApp::Container;

use strict;
use warnings;
use parent 'Pickles::Container';

sub MyApp::ControllerValue::new { bless {}, $_[0] };

__PACKAGE__->register( InitValue => sub {
    MyApp::ControllerValue->new;
});

1;

__END__

