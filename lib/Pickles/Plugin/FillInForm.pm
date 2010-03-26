package Pickles::Plugin::FillInForm;
use strict;
use HTML::FillInForm;

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_trigger( pre_filter => sub {
        my( $c ) = @_;
        if ( $c->req->method eq 'POST' || $c->stash->{fdat} ) {
            $c->add_filter(sub {
                my $body = shift;
                my $q = $c->stash->{fdat} || $c->req->parameters;
                HTML::FillInForm->fill( \$body, $q );
            });
        }
    });
}

1;

__END__
