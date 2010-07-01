package Pickles::Controller;
use strict;
use Class::Trigger qw(pre_action post_action);

sub new {
    my( $class ) = @_;
    my $self = bless {}, $class;
    $self;
}

sub execute {
    my( $self, $name, $c, $args ) = @_;
    $self->call_trigger( 'pre_action', $c );
    $self->$name( $c, $args );
    $self->call_trigger( 'post_action', $c );
}

1;

__END__
