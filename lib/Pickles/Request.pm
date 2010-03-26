package Pickles::Request;
use strict;
use parent 'Plack::Request';

sub uri_for {
    my($self, $path, $args) = @_;
    my $uri = $self->base;
    $uri->path($uri->path . $path);
    $uri->query_form(@$args) if $args;
    $uri;
}


1;

__END__
