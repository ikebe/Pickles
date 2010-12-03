package Pickles::Config;
use strict;
use Carp ();
use File::Spec;
use Path::Class;
use Plack::Util::Accessor qw(appname home);
use Pickles::Util qw(env_value);

sub new {
    my $class = shift;
    my %args = @_;
    my $self = bless {}, $class;
    $self->{appname} = Pickles::Util::appname( $class );
    $self->setup_home( $args{home} );
    $self->{ACTION_PREFIX} = '';
    $self->load_files( $args{files} || [] );
    $self;
}

sub construct {
    my $class = shift;
    my $self = $class->new;
    my $files = $self->get_config_files;
    $self->load_files( $files );
    $self;
}

sub get {
    my( $self, $key, $default ) = @_;
    return defined $self->{$key} ? $self->{$key} : $default;
}

sub setup_home {
    my( $self, $home ) = @_;
    my $dir = 
        $home || env_value( 'HOME', $self->appname ) || $ENV{'PICKLES_HOME'};
    if ( $dir ) {
        $self->{home} = dir( $dir );
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

sub load_files {
    my( $self, $files ) = @_;
    my %config;

    # In 5.8.8 at least, putting $self in an evaled code produces
    # extra warnings (and possibly break the behavior of __path_to)
    # so we create a private closure, and plant the closure into
    # the generated packes
    $self->{__FILES} = [];

    my $path_to = sub { $self->path_to(@_) };
    my $load_file = sub {
        my $file = $path_to->( @_ );
        my $subconf = do $file;
        # death context should be at the calling config file level
        Carp::croak("Could not parse $file: $@") if $@;
        Carp::croak("Could not do $file: $!")    if ! defined $subconf;
        Carp::croak("Could not run $file")       if ! $subconf;

        push @{$self->{__FILES}}, $file;
        return $subconf;
    };

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
            *{"$fqname\::load_file"} = $load_file;
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
    push @{$self->{__FILES}}, @$files;
    $self->{__TIME} = time;
    for my $key( keys %config ) {
        $self->{$key} = $config{$key};
    }
    \%config;
}

sub get_config_files {
    my $self = shift;
    my @files;

    if ( my $config_file = env_value('CONFIG', $self->appname) ) {
        push @files, $self->path_to( $config_file );
    }
    else {
        my @base_files = ( File::Spec->catfile('etc', 'config.pl'), 'config.pl' );
        foreach my $f (@base_files) {
            my $base = $self->path_to($f);
            push @files, $base if -e $base;
        }
    }
    
    if ( my $env = env_value('ENV', $self->appname) ) {
        my @env_files;
        for my $file( @files ) {
            my ($v, $d, $fname) = File::Spec->splitpath( $file );
            $fname =~ s/(\.[^\.]+)?$/$1 ? "_%s$1" : "%s"/e;
            my $template = File::Spec->catpath( $v, $d, $fname );
            my $filename = sprintf $template, $env;
            push @env_files, $self->path_to( $filename );

        }
        push @files, @env_files;
    }
    return \@files;
}

sub path_to {
    my( $self, @path ) = @_;
    if ( File::Spec->file_name_is_absolute( $path[0] ) ) {
        return File::Spec->catfile( @path );
    }
    file( $self->home, @path )->stringify;
}

1;

__END__

=head1 NAME

Pickles::Config - Config Object

=head1 SYNOPSIS

    use MyApp::Config;
    my $config = MyApp::Config->construct;
    my $component = $config->get( $component_name );
    my $path = $config->path_to( $subpath, ... );

=head1 METHODS

=head2 Class->new([ files => \@files, home => $home ]);

create new config object.

=over 4

=item files => \@files

specify the config files.
if relative paths are specified, convert to absolute path from application home.

=item home => $home

specify the application home directory.

=back

=head2 Class->construct;

returns a config object which is based on predefined rules and ENV values.
see CONSTRUCT RULES section.

=head2 $config->home

returns a application home dir's L<Path::Class::Dir> object.

=head2 $config->get( $name, [$default_value] )

get config value.

=head2 $config->path_to( @path )

construct absolute path from application home. 

=head1 CONSTRUCT RULES

following files and env values are used in I<construct>.

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
