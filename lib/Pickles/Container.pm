package Pickles::Container;
use strict;
use base qw(Class::Data::Inheritable);

__PACKAGE__->mk_classdata( __persistent_objects => undef );
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
        $opts ||= {};
        my %data = (
            %$opts,
            initializer => $component,
        );
        $self->components->{ $name } = \%data;
    } else {
        $self->persistent_objects->{$name} = $component;
    }
}

sub get {
    my ($self, $name, @args) = @_;
    my $object = $self->objects->{$name} || $self->persistent_objects->{$name};
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
    $data->{initializer}->( $self, @args );
}

1;

__END__

=head1 NAME

Pickles::Container - A Simple Container

=head1 SYNOPSIS

    package MyApp::Container;
    use base qw(Pickles::Container);

    # a persistent object (lasts during this process)
    my $object = Foo->new();
    __PACKAGE__->register( foo => $object );

    # a per-instance object (lasts only during an instance of 
    # this container is alive)
    __PACKAGE__->register( bar => sub { Bar->new } );

    # a persistent object, lazily instantiated
    __PACKAGE__->register( baz => sub { Baz->new }, { persistent => 1 } );


    # somewhere else in your code
    {
        my $c = MyApp::Container->new();
        my $foo = $c->get('foo');
        my $bar = $c->get('bar'); 
        my $baz = $c->get('baz');
        # $c goes out of scope
    }

    {
        my $c = MyApp::Container->new();
        my $foo = $c->get('foo'); # Same as previous $foo
        my $bar = $c->get('bar'); # DIFFERENT from previous $bar
        my $baz = $c->get('baz'); # Same as previous $baz
    }

=head1 DESCRIPTION

Pickles::Container is a simple container object like Object::Container.

The main difference is that it has per-process lifecycle and per-instance
lifecycle objects.

=cut
