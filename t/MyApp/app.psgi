
use strict;
use MyApp;
use MyApp::Config;
use Plack::Builder;

my $app = MyApp->handler;
my $config = MyApp::Config->instance;

builder {
    enable 'Static',
        path => qr{\.(jpg|gif|png|css|js|ico)$}, root => $config->path_to('htdocs');
    $app;
};


