package Pickles::Config;
use strict;
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
    for my $file( @{$files} ) {
        my $pkg = $file;
        $pkg =~ s/([^A-Za-z0-9_])/sprintf("_%2x", unpack("C", $1))/eg;
        my $config_pkg = sprintf <<'SANDBOX', ref $self, $pkg;
package %s::%s;
sub __path_to {
    $self->path_to(@_);
}
{
    my $conf = do $file or die $!;
    $conf;
}
SANDBOX
        my $conf = eval $config_pkg || +{};
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
    my $base = $self->path_to('config.pl');
    push @files, $base if -e $base;
    if ( my $config_file = env_value('CONFIG', $self->appname) ) {
        if ( $config_file =~ m{^/} ) {
            push @files, $config_file;
        }
        else {
            push @files, $self->path_to( $config_file );
        }
    }
    if ( my $env = env_value('ENV', $self->appname) ) {
        my $filename = sprintf 'config_%s.pl', $env;
        push @files, $self->path_to( $filename );
    }
    return \@files;
}

sub path_to {
    my( $self, @path ) = @_;
    file( $self->home, @path )->stringify;
}

1;

__END__
