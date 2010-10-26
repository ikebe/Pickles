package MyApp::Dispatcher;
use strict;
use base qw(Pickles::Dispatcher);

__PACKAGE__->routes([
    '/' => { controller => 'Root', action => 'index' },
    '/foo' => { controller => 'Root', action => 'foo' },
    '/foo/bar' => { controller => 'Foo', action => 'bar' },
    '/foo/post' => [ { controller => 'Foo', action => 'post', }, { method => 'POST' } ],
    '/redirect' => { controller => 'Root', action => 'redirect' },
    '/redirect2' => { controller => 'Root', action => 'redirect2' },
    '/redirect2' => { controller => 'Root', action => 'redirect2' },
    '/redirect_and_abort' => { controller => 'Root', action => 'redirect_and_abort' },
    '/form' => { controller => 'Root', action => 'form' },
    '/count' => { controller => 'Root', action => 'count' },
]);

__PACKAGE__->connect( 
    '/items/:id' => { 'controller' => 'Item', action => 'view', } 
);

1;

__END__
