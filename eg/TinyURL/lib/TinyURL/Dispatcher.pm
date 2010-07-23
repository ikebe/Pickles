package TinyURL::Dispatcher;
use strict;
use base qw(Pickles::Dispatcher);

__PACKAGE__->routes([
    '/' => { controller => 'Root', action => 'index' },
    '/add' => { controller => 'Root', action => 'add', },
    '/:id' => { controller => 'Root', action => 'go' },
]);

1;

__END__
