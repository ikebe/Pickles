package Pickles::WebApp;
use strict;
use base qw(Class::Data::Inheritable);
use Plack::Util;

__PACKAGE__->mk_classdata( 'context_class' => 'Context' );

sub handler {
    my $class = shift;
    my $app = sub {
        my $env = shift;
        my $c = $class->create_context(
            env => $env,
        );
        $c->dispatch;
    };
    $app;
}

sub create_context {
    my $class = shift;
    my %args = @_;
    my $context_class = 
        Plack::Util::load_class( $class->context_class, $class );
    $context_class->new( %args );
}


1;

__END__
