
use strict;
use Plack::Test;
use lib "./t/MyApp/lib";
use Test::More;
use MyApp::Context;
use MyApp;
use HTTP::Request;
use HTTP::Response;
use HTTP::Message::PSGI;
use MyApp;

eval { 
    require Log::Dispatch; 
};
if ( $@ ) {
    plan skip_all => "Log::Dispatch is not installed";
}
else {
    plan tests => 1;
}


{
    my $req = HTTP::Request->new( GET => 'http://localhost/' );
    local *STDERR;
    open STDERR, '>', \my $stderr;
    MyApp::Context->load_plugins(qw(Log));
    my $c = MyApp->create_context( env => $req->to_psgi );
    $c->log->debug('XXX');
    is $stderr, "XXX\n";
}




