package TinyURL::Controller::Root;
use strict;
use warnings;
use parent 'Pickles::Controller';

sub index {
    my( $self, $c ) = @_;
}

sub add {
    my( $self, $c ) = @_;
    if ( $c->req->method eq 'POST' ) {
        my $code = $c->get('DB')->add( $c->req->param('url') );
        $c->stash->{result} = $c->uri_for( '/', $code );
    }
}

sub go {
    my( $self, $c ) = @_;
    my $id = $c->args->{id};
    my $url = $c->get('DB')->lookup( $id );
    $c->redirect( $url );
}

1;

__END__

