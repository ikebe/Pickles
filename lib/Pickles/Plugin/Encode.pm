package Pickles::Plugin::Encode;
use strict;
use Encode ();

sub _decode {
    my ($hmv, $ie) = @_;
    for my $key( $hmv->keys ) {
        my @values = map { Encode::decode($ie, $_) } $hmv->get_all( $key );
        $hmv->remove( $key );
        $hmv->add( $key => @values );
    }
}

sub install {
    my( $class, $pkg ) = @_;
    $pkg->add_trigger( init => sub {
        my $c = shift;
        my $config = $c->config->{'Plugin::Encode'};
        my $ie = $config->{input_encoding} || 'utf-8';
        _decode( $c->req->query_parameters, $ie );
        _decode( $c->req->body_parameters, $ie );
        delete $c->req->env->{'plack.request.merged'}; # make sure
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
