package Pickles::WebApp;
use strict;
use Plack::Util;
use String::CamelCase qw(camelize);

sub handler {
    my $class = shift;
    my $context_class = Plack::Util::load_class( 'Context', $class );

    my $dispatcher_class = Plack::Util::load_class( 'Dispatcher', $class );
    my $routes = $dispatcher_class->instance->routes;
    if ($routes) {
        my %seen;
        for my $i (0..(@$routes/2 - 1)) {
            my $path = $routes->[$i * 2];
            my $config = $routes->[$i * 2 + 1];
            if (ref $config eq 'ARRAY') {
                $config = $config->[0];
            }
            my $controller = $config->{controller};
            if (! $controller) {
                warn "No controller specified for path $path";
            }

            next if $seen{ $controller }++;
            Plack::Util::load_class( "Controller::" . camelize($controller), $class );
        }
    }

    my $app = sub {
        my $env = shift;
        my $c = $context_class->new( $env );
        $c->dispatch;
    };
    $app;
}

1;

__END__
