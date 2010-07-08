package MyApp::Dispatcher;
use strict;
use base qw(Pickles::Dispatcher);

__PACKAGE__->routes([
    '/' => { controller => 'Root', action => 'index' },
    '/foo' => { controller => 'Root', action => 'foo' },
]);

1;

__END__
