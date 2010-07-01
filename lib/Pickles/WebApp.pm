package Pickles::WebApp;
use strict;
use Plack::Util;

sub handler {
    my $class = shift;
    my $context_class = Plack::Util::load_class( 'Context', $class );
    my $app = sub {
        my $env = shift;
        my $c = $context_class->new( $env );
        $c->dispatch;
    };
    $app;
}

1;

__END__
