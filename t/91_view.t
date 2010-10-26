
use strict;
use Plack::Test;
use Test::More tests => 13;
use MyApp;

my $tested = 0;

# TT view
SKIP:
{
    eval { require Template; };
    skip "Template is not installed", 4 if $@;
    test_psgi
        app => MyApp->handler,
            client => sub {
                my $cb = shift;
                my $req = HTTP::Request->new( GET => 'http://localhost/foo/bar' );
                my $res = $cb->( $req );
                is $res->code, '200';
                like $res->content, qr{Foo/Bar}, 'check content';
                like $res->content, qr{MyApp - Template}, 'check content';
                like $res->content, qr{var1}, 'check content';
                $tested++;
            } ;
}

# MT view
SKIP:
{
    eval { require Text::MicroTemplate::Extended; };
    skip "Text::MicroTemplate::Extended is not installed", 4 if $@;
    test_psgi
        app => MyApp->handler,
            client => sub {
                my $cb = shift;
                my $req = HTTP::Request->new( GET => 'http://localhost/foo/bar?view=MT' );
                my $res = $cb->( $req );
                is $res->code, '200';
                like $res->content, qr{Foo/Bar}, 'check content';
                like $res->content, qr{MyApp - MicroTemplate}, 'check content';
                like $res->content, qr{var1}, 'check content';
                $tested++;
            } ;
}

# Xslate view
SKIP: 
{
    eval { require Text::Xslate; };
    skip "Text::Xslate is not installed", 4 if $@;
    test_psgi
        app => MyApp->handler,
            client => sub {
                my $cb = shift;
                my $req = HTTP::Request->new( GET => 'http://localhost/foo/bar?view=Xslate' );
                my $res = $cb->( $req );
                is $res->code, '200';
                like $res->content, qr{Foo/Bar}, 'check content';
                like $res->content, qr{MyApp - Xslate}, 'check content';
                like $res->content, qr{var1}, 'check content';
                $tested++;
            } ;
}

ok $tested, "Tested $tested view types. Make sure to install at least one of Template-Toolkit, Text::MicroTemplate::Extended, or Text::Xslate";
