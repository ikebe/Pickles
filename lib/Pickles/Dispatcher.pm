package Pickles::Dispatcher;
use strict;
use Router::Simple;
use base qw(Class::Data::Inheritable);
use Carp ();

__PACKAGE__->mk_classdata('__Routes');

sub instance {
    my $class = shift;
    return $class if ref $class;
    no strict 'refs';
    my $instance = \${ "$class\::_instance" };
    defined $$instance ? $$instance : ($$instance = $class->_init);
}

sub _init {
    my $class = shift;
    my $self = bless {}, $class;
    my $router = Router::Simple->new;
    my @routes = @{$class->__Routes};
    for (@routes) {
        my( $path, $rule ) = splice( @routes, 0, 2 );
        $router->connect( $path, $rule );
    }
    $self->{router} = $router;
    $self;
}

sub router {
    my $self = shift;
    $self->{router};
}

sub match {
    my( $self, $req ) = @_;
    $self->router->match( $req->env );
}

sub routes {
    my( $class, $routes ) = @_;
    $class->__Routes( $routes );
}

sub connect {
    my $class = shift;
    unless ( @_ == 2 ) {
        Carp::croak("Odd number of parameters: @_");
    }
    my $routes = $class->__Routes;
    push @{$routes}, @_;
    $class->__Routes( $routes );
}

1;

__END__
