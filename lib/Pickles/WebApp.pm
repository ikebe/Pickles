package Pickles::WebApp;
use strict;
use base qw(Class::Data::Inheritable);
use Plack::Util;
use Plack::Util::Accessor qw(config dispatcher container);
use Pickles::Util;
use Scalar::Util qw(blessed);

__PACKAGE__->mk_classdata( 'config_class' => 'Config' );
__PACKAGE__->mk_classdata( 'dispatcher_class' => 'Dispatcher' );
__PACKAGE__->mk_classdata( 'context_class' => 'Context' );
__PACKAGE__->mk_classdata( 'container_class' => 'Container' );

sub new {
    my $class = shift;
    my %args = @_;
    my $self = bless { %args }, $class;
    $self->config( $self->setup_config ) unless $self->config;
    $self->dispatcher( $self->setup_dispatcher ) unless $self->dispatcher;
    $self->container( $self->setup_container ) unless $self->container;
    $self;
}

sub handler {
    my $self = shift;
    $self = $self->new unless ref $self;
    my $app = sub {
        my $env = shift;
        my $c = $self->create_context(
            env => $env,
        );
        $c->dispatch;
    };
    $app;
}

sub appname { shift->config->appname; }

sub setup_config {
    my $self = shift;
    my $config_class = 
        Plack::Util::load_class( $self->config_class, ref $self );
    $config_class->construct;
}

sub setup_dispatcher {
    my $self = shift;
    my $dispatcher_class = 
        Plack::Util::load_class( $self->dispatcher_class, $self->appname );
    my $dispatcher = $dispatcher_class->new( file => $self->get_routes_file );
    $dispatcher->load_controllers( $self->appname );
    $dispatcher;
}

sub get_routes_file {
    my $self = shift;
    my $file = Pickles::Util::env_value( 'ROUTES', $self->appname );
    if (! $file) {
        $file = $self->config->path_to( 'etc/routes.pl' );
    }
    return $file;
}

sub setup_container {
    my $self = shift;
    my $container_class = 
        Plack::Util::load_class( $self->container_class, ref $self );
    my $container = $container_class->new;
    $container->register( config => $self->config );
    my $file = $self->get_container_file;
    if ( -e $file ) {
        $container->load( $file );
    } 
    $container;
}

sub get_container_file {
    my $self = shift;
    my $file = Pickles::Util::env_value('CONTAINER_FILE', $self->appname );
    if (! $file) {
        $file = $self->config->path_to( 'etc/container.pl' );
    }
    return $file;
}

sub create_context {
    my $self = shift;
    $self = $self->new unless blessed $self;
    my %args = ( 
        config => $self->config,
        dispatcher => $self->dispatcher,
        container => $self->container,
        @_ 
    );
    my $context_class = 
        Plack::Util::load_class( $self->context_class, $self->appname );
    $context_class->new( %args );
}


1;

__END__

=head1 NAME

Pickles::WebApp - Pickles WebApp base class.

=head1 SYNOPSIS

  package MyApp;
  
  use strict;
  use warnings;
  use parent 'Pickles::WebApp';
   
  1;
  
  __END__

MyApp.psgi

  use strict;
  use MyApp;
  use Plack::Builder;
  
  my $app = MyApp->new->handler;
  builder {
      $app;
  };


=head1 METHODS

=head2 Class->new

returns a new WebApp object.

=head2 $webapp->handler

returns a PSGI application sub-ref.

=head2 $webapp->appname

returns a application name.

=head2 $webapp->setup_config

returns a config object.
if you'd like to use custom config object, override this method.

=head2 $webapp->setup_dispatcher

returns a dispatcher object.
if you'd like to use custom dispatcher object, override this method.

=head2 $webapp->get_routes_file

returns a routes file which is used by dispatcher. the default value is $config->path_to('etc/routes.pl').

=head2 $webapp->setup_container

returns a container object
if you'd like to use custom container object, override this method.

=head2 $webapp->get_container_file

returns a profile file which is used by container. the default value is $config->path_to('etc/container.pl').

=head1 CLASS VARIABLES

The following class variables specify component classes.
Omit the $self->appname prefix from the class name.

    # MyApp::Config
    MyApp->config_class('Config');

    # MyApp::Config::JSON
    MyApp->config_class('Config::JSON');

if you want to use fully qualified class name, use plus sign prefix.

    # Foo::Config
    MyApp->config_class('+Foo::Config');

=head2 MyApp->context_class

default value is C<Context>

=head2 MyApp->config_class

default value is C<Config>

=head2 MyApp->dispatcher_class

default value is C<Dispatcher>

=head2 MyApp::Context->container_class

default value is C<Container>

=head1 AUTHOR

Tomohiro Ikebe E<lt>ikebe {at} livedoor.jpE<gt>

=head1 SEE ALSO

L<Pickles::Context>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
