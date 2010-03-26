package Pickles::View;
use strict;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub render { die 'abstract method!'; }
sub content_type { 'text/html'; }

1;

__END__
