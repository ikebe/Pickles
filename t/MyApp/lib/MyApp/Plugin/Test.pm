package MyApp::Plugin::Test;
use strict;

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_method( test_func => sub {
        'test_func';
    });
}

1;

__END__
