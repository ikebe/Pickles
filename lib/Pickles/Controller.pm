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

sub REPLY {
    my ($self, $c, $status) = @_;

    require HTTP::Status;
    my $res = $c->res;
    $res->status( $status );
    $res->content_type('text/plain');
    $res->body( HTTP::Status::status_message( $status ) );
    return $res;
}

BEGIN {
    foreach my $code (403, 404, 500) {
        no strict 'refs';
        no warnings 'redefine';
        my $method = "res$code";
        *{$method} = sub {
            my ($self, $c) = @_;
            $self->REPLY($c, $code);
            $c->finished(1);
            $c->abort();
        };
    }
}

1;

__END__
