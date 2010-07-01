package Pickles::Dispatcher;
use strict;
use Router::Simple;

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
    my @routes = @{$class->routes};
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
    return [
        '/' => { controller => 'Root', action => 'index', },
    ];
}

1;

__END__
