package MyApp::Controller::Foo;
use strict;
use warnings;
use parent 'Pickles::Controller';

sub bar {
    my( $self, $c ) = @_;
    $c->stash->{var} = 'var1';
    if ( my $view = $c->req->param('view') ) {
        $c->render('View::'. $view);
    } 
}

1;

__END__

