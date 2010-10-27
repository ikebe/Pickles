package Pickles::Container;
use strict;

sub new {
    my $class = shift;
    bless {
        components => {},
        per_request_components => {},
        objects    => {},
    }, $class;
}

sub register {
    my ($self, $name, $component, $opts) = @_;

    if (ref $component eq 'CODE') {
        my %data = (
            %$opts,
            initialzer => $component,
        );

        $self->components->{ $name } = \%data;
        push @{$self->per_request_components}, $name;
        
    } else {
        $self->{objects}->{$name} = $component;
    }
}

sub get {
    my ($self, $name, @args) = @_;
    my $object = $self->objects->{$name};
    if (! $object) {
        $object = $self->construct_object($name, @args);
        if ($object) {
            $self->objects->{$name} = $object;
        }
    }
    return $object;
}

sub construct_object {
    my ($self, $name, @args) = @_;
    my $data = $self->components->{$name};
    if (! $data) {
        return ();
    }

    $data->{initializer}->( @args );
}

sub clear_per_request {
    my $self = shift;

    my $objects = $self->objects;
    foreach my $name (@{ $self->per_request_components }) {
        delete $objects->{ $name };
    }
}

1;