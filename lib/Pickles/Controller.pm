package Pickles::Controller;
use strict;
use Class::Trigger qw(pre_action post_action);

sub new {
    my( $class ) = @_;
    my $self = bless {}, $class;
    $self;
}

sub execute {
    my( $self, $name, $c ) = @_;
    if ( my $code = $self->can( $name ) ) {
        $self->call_trigger( 'pre_action', $c );
        $code->( $self, $c );
        $self->call_trigger( 'post_action', $c );
        return 1;
    }
    return ;
}

1;

__END__
