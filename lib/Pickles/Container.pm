package Pickles::Container;
use strict;
use Carp ();

sub new {
    my ($class, %args) = @_;
    bless {
        components     => {},
        home           => $args{home},
        objects        => {},
        scoped_objects => {},
    }, $class;
}

sub Pickles::Container::ScopeGuard::DESTROY {
    my $self = shift;
    $self->{container}->clear_scope();
}

sub new_scope {
    my $self = shift;
    return bless { container => $self }, 'Pickles::Container::ScopeGuard';
}

sub clear_scope {
    my $self = shift;
    $self->{scoped_objects} = {};
}

sub load {
    my ($self, $file) = @_;

    my $o = \&register;
    no warnings 'redefine';
    local *register = sub($$;$) {
        $o->( $self, @_ );
    };
    local *load_file = sub(@) {
        my $c = $self->get('config');
        # XXX what if there's no config?
        my $file = $c->path_to(@_);
        my $rv = do $file;
        Carp::croak("Failed to parse file $file: $@") if $@;
        Carp::croak("Failed to run file (did you return a true value?)") unless $rv;
        return $rv;
    };
    my $result = do $file;
    die "Failed to parse file $file: $@" if $@;
    die "Failed to run file (did you return a true value?)" unless $result;
    $self;
}

sub components {
    my $self = shift;
    my $h = $self->{components};
    if (! $h) {
        $self->{components} = ($h = {});
    }
    return $h;
}

sub home { $_[0]->{home} }
sub objects { $_[0]->{objects} }
sub scoped_objects { $_[0]->{scoped_objects} }

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
        $self->objects->{$name} = $component;
    }
}

sub get {
    my ($self, $name, @args) = @_;
    my $object = $self->{objects}->{$name} || $self->{scoped_objects}->{$name};
    if (! $object) {
        my $data = $self->components->{ $name };
        $object = $self->_construct_object($data, @args);
        if ($object) {
            if ($data->{persistent}) {
                $self->objects->{$name} = $object;
            } else {
                $self->scoped_objects->{$name} = $object;
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

    # somewhere else in your code
    my $c = MyApp::Container->new();

    # a persistent object (lasts during this process)
    my $object = Foo->new();
    $c->register( foo => $object );

    # a per-instance object (lasts only during an instance of 
    # this container is alive)
    $c->register( bar => sub { Bar->new } );

    # a persistent object, lazily instantiated
    $c->register( baz => sub { Baz->new }, { persistent => 1 } );

    {
        my $guard = $c->new_scope;
        my $foo = $c->get('foo');
        my $bar = $c->get('bar'); 
        my $baz = $c->get('baz');
        # $guard goes out of scope
    }

    {
        my $guard = $c->new_scope;
        my $foo = $c->get('foo'); # Same as previous $foo
        my $bar = $c->get('bar'); # DIFFERENT from previous $bar
        my $baz = $c->get('baz'); # Same as previous $baz
    }

=head1 DESCRIPTION

Pickles::Container is a simple container object like Object::Container.

The main difference is that it has per-process lifecycle and per-instance
lifecycle objects.

=cut
