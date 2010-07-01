package MyApp::Model::Test;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub method1 { 
    my $self = shift;
    ref $self;
}

1;

__END__

