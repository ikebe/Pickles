package Pickles::Util;
use strict;
use Path::Class;
use base qw(Exporter);
use Carp ();

our @EXPORT_OK = qw(env_name env_value);


sub env_name {
    my( $name, $appname ) = @_;
    $appname =~ s/::/_/g;
    return uc(join('_', $appname, $name));
}

sub env_value {
    return $ENV{ env_name(@_) };
}

sub appname {
    my $class = shift;
    if (my $appname = $ENV{PICKLES_APPNAME}) {
        return $appname;
    }
    if ( $class =~ m/^(.*?)::(Context|Config)$/ ) {
        my $appname = $1;
        return $appname;
    }
    Carp::croak("Could not determine APPNAME from either %ENV or classname ($class)");
}

1;

__END__
