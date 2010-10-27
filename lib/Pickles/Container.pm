package Pickles::Container;
use strict;
use base qw(Class::Data::Inheritable);

__PACKAGE__->mk_classdata( __persistent => undef );

sub new {
    my $class = shift;
    bless {
        components => {},
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
        my $h = $self->__persistent();
        if (! $h) {
            $self->__persistent($h = {});
        }
        $h->{$name} = $component;
    }
}

sub get {
    my ($self, $name, @args) = @_;
    my $h = $self->__persistent();
    if (! $h) {
        $self->__persistent($h = {});
    }
    my $object = $h->{$name};

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

1;