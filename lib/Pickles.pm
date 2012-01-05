package Pickles;

use strict;
use warnings;
our $VERSION = '0.10';

1;
__END__

=head1 NAME

Pickles - simple web application framework

=head1 SYNOPSIS

  % pickles-setup MyApp
  % cd MyApp
  % plackup MyApp.psgi

  ## etc/routes.pl
  router {
      connect '/' => { controller => 'Root', action => 'index' };
  };

  ## etc/config.pl

  return +{};

  ## lib/MyApp/Context.pm
  package MyApp::Context;
  
  use strict;
  use warnings;
  use parent 'Pickles::Context';
  use MyApp::Model::Test;
  
  __PACKAGE__->load_plugins(qw(Encode));

  ## lib/MyApp/Controller/Root.pm
  package MyApp::Controller::Root;
  use strict;
  use warnings;
  use parent 'Pickles::Controller';
  
  sub index {
      my( $self, $c ) = @_;
  }
  
  1;
  
  __END__
  
  ## view/index.html
  # Text::Xslate with TTerse syntax.
  <html>
  <head>
      <title>[% c.appname | html %]</title>
  </head>
  <body>
  <h1>Hello [% c.appname | html %]!</h1>
  </body>
  </html>


=head1 DESCRIPTION

Pickles is a simple web application framework, which is based upon L<Plack>.

=head1 AUTHOR

Tomohiro Ikebe E<lt>ikebe {at} livedoor.jpE<gt>

=head1 SEE ALSO

L<Plack>, L<Sledge>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
