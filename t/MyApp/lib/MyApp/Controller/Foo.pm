package MyApp::Controller::Foo;
use strict;
use warnings;
use parent 'Pickles::Controller';
use Encode;

sub init {
    my( $self, $c ) = @_;
    $self->{InitValue} = $c->get('InitValue');
}

sub bar {
    my( $self, $c ) = @_;
    $c->stash->{var} = 'var1';
    if ( my $view = $c->req->param('view') ) {
        $c->render('View::'. $view);
    } 
}

sub post {
    my( $self, $c ) = @_;
    my $res = $c->res;
    $res->content_type('text/plain');
    $res->body( 'method was ' . $c->req->method );
    $c->finished(1);
}

sub multibyte_args {
    my( $self, $c ) = @_;
    my $args = $c->args;
    $c->res->content_type('text/plain');
    $c->res->body('ok');
    $c->finished(1);
}

sub force_status {
    my( $self, $c ) = @_;
    my $status = $c->req->param('status');
    my $method = "res$status";
    $self->$method($c);
}

sub error {
    die "pickles.intentional.error";
}

1;

__END__

