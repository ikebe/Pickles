package Pickles::WebApp;
use strict;
use base qw(Class::Data::Inheritable);
use Plack::Util;
use Plack::Util::Accessor qw(context);
use String::CamelCase qw(camelize);

__PACKAGE__->mk_classdata( 'context_class' => 'Context' );

sub new { 
    my $class = shift;
    return bless { @_ }, $class
}

sub handler {
    my $class = shift;
    my $context_class = $class->context_class || 'Context';
    $context_class = Plack::Util::load_class( $context_class, $class );
    $context_class->setup;

    my $self = $class->new(
        context => $context_class->new()
    );
    
    my $app = sub {
        my $env = shift;
        my $c = $self->context;
        my $guard = $c->new_request( $env );
        $c->dispatch;
    };
    $app;
}

1;

__END__
