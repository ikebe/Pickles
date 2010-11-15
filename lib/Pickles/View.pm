package Pickles::View;
use strict;
use base qw(Class::Data::Inheritable);

__PACKAGE__->mk_classdata(qw(__Config));

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub render { die 'abstract method!'; }
sub content_type { 'text/html'; }

sub config {
    my $class = shift;
    return ($class->__Config || {}) unless @_;
    my $values = $_[0];
    if ( @_ > 1 ) {
        $values = { @_ };
    }
    $class->__Config( $values );
}

sub merge_config {
    my( $self, $c ) = @_;

    my $class = ref $self;
    my $appname = $c->config->appname;
    (my $config_key = $class) =~ s/^${appname}:://;
    my $config = $c->config->{$config_key} || {};
    my %config = (
        %{$self->config},
        %{$config},
    );
    return \%config;
}

1;

__END__
