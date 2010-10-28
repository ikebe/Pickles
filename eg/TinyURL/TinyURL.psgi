
use strict;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir( dirname(__FILE__), 'lib' );

use Plack::Builder;
use TinyURL;
use TinyURL::Config;

my $app = TinyURL->handler;
my $config = TinyURL::Config->new;

builder {
    enable 'Static',
        path => qr{\.(jpg|gif|png|css|js|ico)$}, root => $config->path_to('htdocs');
    $app;
};


