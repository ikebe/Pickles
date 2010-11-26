package Pickles::Plugin::Encode;
use strict;
use Encode;

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_trigger( init => sub {
        my $c = shift;
        my $config = $c->config->{'Plugin::Encode'};
        my $ie = $config->{input_encoding} || 'utf-8';
        # params is-a Hash::MultiValue-
        for my $key( keys %{$c->req->parameters} ) {
            my @values;
            for my $val( $c->req->parameters->get_all( $key ) ) {
                push @values, Encode::decode($ie, $val);
            }
            $c->req->parameters->remove( $key );
            $c->req->parameters->add( $key => @values );
        }
    });
    $pkg->add_trigger( pre_finalize => sub {
        my( $c ) = @_;
        if ( $c->res->content_type =~ m{^text/} ) {
            my $body = $c->res->body;
            my $config = $c->config->{'Plugin::Encode'};
            my $oe = $config->{output_encoding} || 'utf-8';
            $c->res->content_type( $c->res->content_type. '; charset='. $oe );
            $c->res->body( Encode::encode( $oe, $body ) );
        }
    });
}

1;

__END__
