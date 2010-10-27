package Pickles::Container;
use strict;
use base qw(Class::Data::Inheritable);

__PACKAGE__->mk_classdata( __persistent => undef );
__PACKAGE__->mk_classdata( __components => undef );

sub new {
    my $class = shift;
    bless {
        objects    => {},
    }, $class;
}

sub objects { $_[0]->{objects} }

sub components {
    my $self = shift;
    my $h = $self->__components();
    if (! $h) {
        $self->__components($h = {});
    }
    return $h;
}

sub persistent_objects {
    my $self = shift;
    my $h = $self->__persistent_objects();
    if (! $h) {
        $self->__persistent_objects($h = {});
    }
    return $h;
}

sub register {
    my ($self, $name, $component, $opts) = @_;

    if (ref $component eq 'CODE') {
        my %data = (
            %$opts,
            initialzer => $component,
        );
        $self->components->{ $name } = \%data;
    } else {
        $self->persistent_objects->{$name} = $component;
    }
}

sub get {
    my ($self, $name, @args) = @_;
    my $object = $self->persisntent_objects->{$name};
    if (! $object) {
        my $data = $self->components->{ $name };
        $object = $self->_construct_object($data, @args);
        if ($object) {
            if ($data->{persistent}) {
                $self->persistent_objects->{$name} = $object;
            } else {
                $self->objects->{$name} = $object;
            }
        }
    }
    return $object;
}

sub _construct_object {
    my ($self, $data, @args) = @_;
    if (! $data) {
        return ();
    }

    $data->{initializer}->( @args );
}

1;