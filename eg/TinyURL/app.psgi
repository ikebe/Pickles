
use strict;
use TinyURL;
use TinyURL::Config;
use Plack::Builder;

my $app = TinyURL->handler;
my $config = TinyURL::Config->instance;

builder {
    enable 'Static',
        path => qr{\.(jpg|gif|png|css|js|ico)$}, root => $config->path_to('htdocs');
    $app;
};


