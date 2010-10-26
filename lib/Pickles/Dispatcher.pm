package Pickles::Dispatcher;
use strict;
use Router::Simple;
use Carp ();

sub new {
    my ($class, %args) = @_;

    my $file = $args{file} || Carp::croak("No file given to $class->new");
    my $pkg = $file;
    $pkg =~ s/([^A-Za-z0-9_])/sprintf("_%2x", unpack("C", $1))/eg;

    my $fqname = sprintf '%s::%s', $class, $pkg;
    my $router_pkg = sprintf <<'SANDBOX', $fqname;
package %s;
use Router::Simple::Declare;
{
    my $conf = do $file or die $!;
    $conf;
}
SANDBOX
    my $router = eval $router_pkg;
    if (! eval { $router->isa( 'Router::Simple' ) } || $@ ) {
        Carp::croak("file $args{file} returned something other than Router::Simple");
    }
    bless { router => $router }, $class;
}

sub router {
    my $self = shift;
    $self->{router};
}

sub match {
    my( $self, $req ) = @_;
    my $match = $self->router->match( $req->env );
    my %args;
    for my $key( keys %{$match} ) {
        next if $key =~ m{^(controller|action)$};
        $args{$key} = delete $match->{$key};
    }
    $match->{args} = \%args;
    $match;
}

1;

__END__
