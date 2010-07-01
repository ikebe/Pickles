package MyApp::Dispatcher;
use strict;
use HTTPx::Dispatcher;

connect '/' => {
    controller => 'Root',
    action => 'index',
};

1;

__END__
