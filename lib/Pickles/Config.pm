package Pickles::Config;
use strict;
use File::Spec;
use Path::Class;
use Plack::Util::Accessor qw(appname home);
use Pickles::Util qw(env_value);

sub instance {
    my $class = shift;
    return $class if ref $class;
    no strict 'refs';
    my $instance = \${ "$class\::_instance" };
    defined $$instance ? $$instance : ($$instance = $class->_load);
}


sub _load {
    my $class = shift;
    my $self = bless {}, $class;
    (my $appname = $class) =~ s/::Config$//;
    $self->{appname} = $appname;
    $self->{ACTION_PREFIX} = '';
    $self->setup_home;
    $self->load_config;
    $self;
}

sub get {
    my( $self, $key, $default ) = @_;
    return defined $self->{$key} ? $self->{$key} : $default;
}

sub setup_home {
    my $self = shift;
    if ( my $home = env_value('HOME', $self->appname) ) { # MYAPP_HOME
        $self->{home} = dir( $home );
    }
    elsif ($ENV{'PICKLES_HOME'}) {
        $self->{home} = dir( $ENV{'PICKLES_HOME'} );
    }
    else {
        my $class = ref $self;
        (my $file = "$class.pm") =~ s|::|/|g;
        if (my $inc_path = $INC{$file}) {
            (my $path = $inc_path) =~ s/$file$//;
            my $home = dir($path)->absolute->cleanup;
            $home = $home->parent while $home =~ /b?lib$/;
            $self->{home} = $home;
        }
    }
}

sub load_config {
    my $self = shift;
    my $files = $self->get_config_files;
    my %config;

    # In 5.8.8 at least, putting $self in an evaled code produces
    # extra warnings (and possibly break the behavior of __path_to)
    # so we create a private closure, and plant the closure into
    # the generated packes
    my $path_to = sub { $self->path_to(@_) };

    for my $file( @{$files} ) {
        # only do this if the file exists
        next unless -e $file;

        my $pkg = $file;
        $pkg =~ s/([^A-Za-z0-9_])/sprintf("_%2x", unpack("C", $1))/eg;

        my $fqname = sprintf '%s::%s', ref $self, $pkg;
        { # XXX This is where we plant that closure
            no strict 'refs';
            no warnings 'redefine';
            *{"$fqname\::__path_to"} = $path_to;
        }

        my $config_pkg = sprintf <<'SANDBOX', $fqname;
package %s;
{
    my $conf = do $file or die $!;
    $conf;
}
SANDBOX
        my $conf = eval $config_pkg || +{};
        if ($@) {
            warn "Error while trying to read config file $file: $@";
        }
        %config = (
            %config,
            %{$conf},
        );
    }
    $self->{__FILES} = $files;
    $self->{__TIME} = time;
    for my $key( keys %config ) {
        $self->{$key} = $config{$key};
    }
    \%config;
}

sub get_config_files {
    my $self = shift;
    my @files;

    my @base_files = ( File::Spec->catfile('etc', 'config.pl'), 'config.pl' );
    foreach my $f (@base_files) {
        my $base = $self->path_to($f);
        push @files, $base if -e $base;
    }

    my $myconfig_file;
    if ( $myconfig_file = env_value('CONFIG', $self->appname) ) {
        if ( $myconfig_file !~ m{^/} ) {
            $myconfig_file = $self->path_to( $myconfig_file );
        }
        push @files, $myconfig_file;
    }
    if ( my $env = env_value('ENV', $self->appname) ) {
        my $template;
        if (! $myconfig_file) {
            $template = File::Spec->catfile('etc', 'config_%s.pl');
        } else {
            my ($v, $d, $file) = File::Spec->splitpath( $myconfig_file );
            $file =~ s/(\.[^\.]+)?$/$1 ? "_%s$1" : "%s"/e;
            $template = File::Spec->catpath( $v, $d, $file );
        }
        my $filename = sprintf $template, $env;
        if ( $filename !~ m{^/}) {
            $filename = $self->path_to( $filename );
        }
        push @files, $filename;
    }
    return \@files;
}

sub path_to {
    my( $self, @path ) = @_;
    file( $self->home, @path )->stringify;
}

1;

__END__

=head1 NAME

Pickles::Config - Config Object

=head1 SYNOPSIS

    use MyApp::Config;
    my $config = MyApp::Config->instance;
    my $component = $config->get( $component_name );
    my $path = $config->path_to( $subpath, ... );

=head1 FILES

=over 4

=item etc/config.pl 

This file is always read, and will be read first. Use it to populate
sane defaults for your app

=item config.pl

This file is read after etc/config.pl, and is read only for backwards
compatibility. THIS FEATURE WILL BE REMOVED IN THE FUTURE.

=item MYAPP_ENV

If you set the environment variable MYAPP_ENV, Pickles will go and read
a config file named using that term. For example, if you set MYAPP_ENV to be
C<'test'>, then it Pickles will attemp to read C<'config_test.pl'>.

NOTE: The name 'MYAPP_ENV' should be changed according to your app name. For example, If you built a Pickles app named Foo::Bar, then the environment variable that you want to set is FOO_BAR_ENV, not MYAPP_ENV

NOTE: The filename that this environment affects also dependson the value of MYAPP_CONFIG. See below.

=item MYAPP_CONFIG

If you set the environment variable MYAPP_CONFIG, Pickles will go and read
that file. Use this to specify an alternate config file.

NOTE: The name 'MYAPP_CONFIG' should be changed according to your app name. For example, If you built a Pickles app named Foo::Bar, then the environment variable that you want to set is FOO_BAR_CONFIG, not MYAPP_CONFIG

This value is subsequently use in the MYAPP_ENV. For example, if you set
MYAPP_CONFIG to be C<'foo.pl'>, then setting MYAPP_ENV to C<'test'> will trigger Pickles to read foo_test.pl, not config_test.pl

=back

=cut
