package MyApp::Controller::Root;
use strict;
use warnings;
use parent 'Pickles::Controller';

sub index {
    my( $self, $c ) = @_;
}

sub foo {
    my( $self, $c ) = @_;
}

sub redirect {
    my( $self, $c ) = @_;
    $c->redirect( '/' );
}

sub redirect2 {
    my( $self, $c ) = @_;
    $c->redirect( 'http://search.cpan.org/' );
}

sub redirect_and_abort {
    my( $self, $c ) = @_;
    $c->redirect( 'http://www.livedoor.com/' );
    $c->abort;
    $c->res->status(200);
    die 'XXX'; 
}

sub form {
    my( $self, $c ) = @_;
}

sub api {
    my( $self, $c ) = @_;
    
    $c->res->body('ok');
    $c->finished(1);
}

sub count {
    my( $self, $c ) = @_;
    my $count = $c->session->get('count');
    $c->session->set( count => ++$count );
    $c->stash->{count} = $count;
}


1;

__END__

