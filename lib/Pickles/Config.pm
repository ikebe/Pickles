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
    $self->setup_home;
    $self->load_config;
    $self;
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
        my $conf = require $file;
        %config = (
            %config,
            %{$conf},
        );
    }
    $self->{__files} = $files;
    $self->{__time} = time;
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
