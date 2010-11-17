
package Pickles::Setup::Flavor;
use strict;
use warnings;
use base 'Module::Setup::Flavor';
use Pickles;

1;

=head1

Pickles::Setup::Flavor - pack from Pickles::Setup::Flavor

=head1 SYNOPSIS

  Pickles::Setup::Flavor-setup --init --flavor-class=+Pickles::Setup::Flavor new_flavor

=cut

__DATA__

---
file: ____var-dist-var____.psgi
template: |+2
  
  use strict;
  use File::Spec;
  use File::Basename;
  use lib File::Spec->catdir( dirname(__FILE__), 'lib' );

  use Plack::Builder;
  use [% module %];

  my $webapp = [% module %]->new;
  my $app = $webapp->handler;
  my $config = $webapp->config;
  
  builder {
      enable 'Static',
          path => qr{^/static/}, root => $config->path_to('htdocs');
      $app;
  };
  

---
file: Changes
template: |
  Revision history for Perl extension [% module %]
  
  0.01    [% localtime %]
          - original version
---
file: etc/config.pl
template: "\nreturn +{};\n\n"
---
file: Makefile.PL
template: |
  use inc::Module::Install;
  name '[% dist %]';
  all_from 'lib/[% module_path %].pm';
  
  # requires '';

  requires 'Pickles' => [% config.pickles_version %];
  
  tests 't/*.t';
  author_tests 'xt';
  
  test_requires 'Test::More';
  auto_include;
  WriteAll;
---
file: MANIFEST.SKIP
template: |
  \bRCS\b
  \bCVS\b
  ^MANIFEST\.
  ^Makefile$
  ~$
  ^#
  \.old$
  ^blib/
  ^pm_to_blib
  ^MakeMaker-\d
  \.gz$
  \.cvsignore
  ^t/9\d_.*\.t
  ^t/perlcritic
  ^tools/
  \.svn/
  \.git/
  ^[^/]+\.yaml$
  ^[^/]+\.pl$
  ^\.shipit$
---
file: README
template: |
  This is Perl module [% module %].
  
  INSTALLATION
  
  [% module %] installation is straightforward. If your CPAN shell is set up,
  you should just be able to do
  
      % cpan [% module %]
  
  Download it, unpack it, then build it as per the usual:
  
      % perl Makefile.PL
      % make && make test
  
  Then install it:
  
      % make install
  
  DOCUMENTATION
  
  [% module %] documentation is available as in POD. So you can do:
  
      % perldoc [% module %]
  
  to read the documentation online with your favorite pager.
  
  [% config.author %]
---
file: htdocs/DUMMY
template: "\n"
---
file: lib/____var-module_path-var____.pm
template: |
  package [% module %];
  
  use strict;
  use warnings;
  use parent 'Pickles::WebApp';
  our $VERSION = '0.01';
  
  1;
  __END__
  
  =head1 NAME
  
  [% module %] -
  
  =head1 SYNOPSIS
  
    use [% module %];
  
  =head1 DESCRIPTION
  
  [% module %] is
  
  =head1 AUTHOR
  
  [% config.author %] E<lt>[% config.email %]E<gt>
  
  =head1 SEE ALSO
  
  =head1 LICENSE
  
  This library is free software; you can redistribute it and/or modify
  it under the same terms as Perl itself.
  
  =cut
---
file: lib/____var-module_path-var____/Config.pm
template: |+
  package [% module %]::Config;
  
  use strict;
  use warnings;
  use parent 'Pickles::Config';
  
  1;
  
  __END__

---
file: lib/____var-module_path-var____/Context.pm
template: |+
  package [% module %]::Context;
  
  use strict;
  use warnings;
  use parent 'Pickles::Context';
  
  __PACKAGE__->load_plugins(qw(Encode));
  
  1;
  
  __END__
---
file: lib/____var-module_path-var____/Container.pm
template: |+
  package [% module %]::Container;
  
  use strict;
  use warnings;
  use parent 'Pickles::Container';
  
  1;
  
  __END__
---
file: etc/routes.pl
template: |+
  router {
      connect '/' => { controller => 'Root', action => 'index' };
  };
---
file: lib/____var-module_path-var____/Dispatcher.pm
template: |
  package [% module %]::Dispatcher;
  use strict;
  use parent qw(Pickles::Dispatcher);
  
  1;
  
  __END__
---
file: lib/____var-module_path-var____/View.pm
template: |+
  package [% module %]::View;
  
  use strict;
  use warnings;
  use parent 'Pickles::View::Xslate';

  __PACKAGE__->config(
      module => [ 'Text::Xslate::Bridge::TT2Like' ],
      syntax => 'TTerse',
      suffix => '.html',
  );
  
  1;
  
  __END__

---
file: lib/____var-module_path-var____/Controller/Root.pm
template: |+
  package [% module %]::Controller::Root;
  use strict;
  use warnings;
  use parent 'Pickles::Controller';
  
  sub index {
      my( $self, $c ) = @_;
  }
  
  1;
  
  __END__

---
file: t/00_compile.t
template: |
  use strict;
  use Test::More tests => 1;
  
  BEGIN { use_ok '[% module %]' }
---
file: view/index.html
template: |
  <html>
  <head>
      <title>[% '[' _ '% c.appname | html %' _ ']' %]</title>
  </head>
  <body>
  <h1>Hello [% '[' _ '% c.appname | html %' _ ']' %]!</h1>
  </body>
  </html>
---
file: xt/01_podspell.t
template: |
  use Test::More;
  eval q{ use Test::Spelling };
  plan skip_all => "Test::Spelling is not installed." if $@;
  add_stopwords(map { split /[\s\:\-]/ } <DATA>);
  $ENV{LANG} = 'C';
  all_pod_files_spelling_ok('lib');
  __DATA__
  [% config.author %]
  [% config.email %]
  [% module %]
---
file: xt/02_perlcritic.t
template: |
  use strict;
  use Test::More;
  eval {
      require Test::Perl::Critic;
      Test::Perl::Critic->import( -profile => 'xt/perlcriticrc');
  };
  plan skip_all => "Test::Perl::Critic is not installed." if $@;
  all_critic_ok('lib');
---
file: xt/03_pod.t
template: |
  use Test::More;
  eval "use Test::Pod 1.00";
  plan skip_all => "Test::Pod 1.00 required for testing POD" if $@;
  all_pod_files_ok();
---
file: xt/perlcriticrc
template: |
  [TestingAndDebugging::ProhibitNoStrict]
  allow=refs
---
config:
  class: Pickles::Setup::Flavor
  module_setup_flavor_devel: 1
  plugins:
    - Config::Basic
    - Template


