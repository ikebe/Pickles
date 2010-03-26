package Pickles::Util;
use strict;
use Path::Class;
use UNIVERSAL::require;
use base qw(Exporter);

our @EXPORT_OK = qw(env_name env_value);


sub env_name {
    my( $name, $appname ) = @_;
    $appname =~ s/::/_/g;
    return uc(join('_', $appname, $name));
}

sub env_value {
    return $ENV{ env_name(@_) };
}

1;

__END__
