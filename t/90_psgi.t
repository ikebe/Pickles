
use strict;
use Plack::Test;
use Test::More;
use MyApp;

# Index
test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/' );
        my $res = $cb->( $req );
        is $res->code, '200';
        like $res->content, qr/Hello MyApp/, 'check content';
    } ;

# Another Page
test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/foo' );
        my $res = $cb->( $req );
        is $res->code, '200';
        like $res->content, qr/Foo/, 'check content';
    } ;

test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/foo/post' );
        my $res = $cb->( $req );
        is $res->code, '404';

        $res = $cb->( HTTP::Request->new( POST => 'http://localhost/foo/post' ) );
        is $res->code, '200';
        is $res->content, 'method was POST';
    } ;

# Handle args.
test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/items/1' );
        my $res = $cb->( $req );
        is $res->code, '200';
        like $res->content, qr/ID:1/, 'check content';
    } ;

# :action style.
test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/bar/baz' );
        my $res = $cb->( $req );
        is $res->code, '200';
    } ;

test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/bar/add_trigger' );
        my $res = $cb->( $req );
        is $res->code, '404';
    } ;

test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/bar/xxx' );
        my $res = $cb->( $req );
        is $res->code, '500';
    } ;

# 404 Not Found.
test_psgi
    app => MyApp->handler,
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new( GET => 'http://localhost/aaa/bbb/ccc' );
        my $res = $cb->( $req );
        is $res->code, '404';
    } ;

done_testing();
