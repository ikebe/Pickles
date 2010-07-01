
use strict;
use Plack::Test;
use Test::More tests => 2;
use lib "./t/MyApp/lib";
use MyApp;

test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/' );
        my $res = $cb->( $req );
        is $res->code, '200';
        like $res->content, qr/Hello MyApp/, 'Hello MyApp';
    } ;

