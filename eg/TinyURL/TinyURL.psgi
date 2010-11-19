
use strict;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir( dirname(__FILE__), 'lib' );

use Plack::Builder;
use TinyURL;

my $webapp = TinyURL->new;
my $config = $webapp->config;

builder {
    enable 'Static',
        path => qr{\.(jpg|gif|png|css|js|ico)$}, root => $config->path_to('htdocs');
    $webapp->handler;
};


