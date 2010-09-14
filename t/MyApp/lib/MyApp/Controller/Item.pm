package MyApp::Controller::Item;
use strict;
use warnings;
use parent 'Pickles::Controller';

sub view {
    my( $self, $c ) = @_;
    $c->stash->{'VIEW_TEMPLATE'} = 'item/view.html';
    my $args = $c->args;
    $c->stash->{id} = $args->{id};
}

1;

__END__

