
use strict;
use Plack::Test;
use Test::More tests => 8;
use MyApp::Dispatcher;
use MyApp::Context;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;

my $dispatcher = MyApp::Dispatcher->new( file => 't/MyApp/etc/routes.pl' );
isa_ok( $dispatcher, 'MyApp::Dispatcher' );

{
    my $req = HTTP::Request->new( GET => 'http://localhost/foo' );
    my $env = $req->to_psgi;
    my $c = MyApp::Context->new( $env );
    
    ok( my $match = $dispatcher->match( $c ) );
    is( $match->{controller}, 'Root' );
    is( $match->{action}, 'foo' );
}

{
    my $req = HTTP::Request->new( GET => 'http://localhost/items/1' );
    my $env = $req->to_psgi;
    my $c = MyApp::Context->new( $env );
    
    ok( my $match = $dispatcher->match( $c ) );
    is( $match->{controller}, 'Item' );
    is( $match->{action}, 'view' );
    is( $match->{args}->{id}, '1' );
}


