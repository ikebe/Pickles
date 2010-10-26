package Pickles::WebApp;
use strict;
use base qw(Class::Data::Inheritable);
use Plack::Util;
use String::CamelCase qw(camelize);

__PACKAGE__->mk_classdata( 'context_class' => 'Context' );

sub handler {
    my $class = shift;
    my $context_class = $class->context_class || 'Context';
    $context_class = Plack::Util::load_class( $context_class, $class );
    $context_class->setup;
    my $app = sub {
        my $env = shift;
        my $c = $context_class->new( $env );
        $c->dispatch;
    };
    $app;
}

1;

__END__
