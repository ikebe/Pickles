package Pickles::Controller;
use strict;
use Class::Trigger qw(pre_action post_action);

sub new {
    my( $class ) = @_;
    my $self = bless {}, $class;
    $self;
}

sub init {
    my( $self, $c ) = @_;
}

sub execute {
    my( $self, $action, $c ) = @_;
    my $config = $c->config;
    if ( my $prefix = $config->{'ACTION_PREFIX'} ) {
        $action = $prefix. $action;
    }
    $self->call_trigger( 'pre_action', $c, $action );
    $self->$action( $c );
    $self->call_trigger( 'post_action', $c, $action );
    return 1;
}

1;

__END__
