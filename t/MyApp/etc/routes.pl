router {
    connect '/' => { controller => 'Root', action => 'index' };
    connect '/foo' => { controller => 'Root', action => 'foo' };
    connect '/foo/bar' => { controller => 'Foo', action => 'bar' };
    connect '/foo/post' => { controller => 'Foo', action => 'post', }, { method => 'POST' };
    connect '/redirect' => { controller => 'Root', action => 'redirect' };
    connect '/redirect2' => { controller => 'Root', action => 'redirect2' };
    connect '/redirect2' => { controller => 'Root', action => 'redirect2' };
    connect '/redirect_and_abort' => { controller => 'Root', action => 'redirect_and_abort' };
    connect '/form' => { controller => 'Root', action => 'form' };
    connect '/form2' => { controller => 'Root', action => 'form' };
    connect '/form3' => { controller => 'Root', action => 'form' };
    connect '/form_skip' => { controller => 'Root', action => 'form', skip_csrf_check => 1 };
    connect '/form_get' => { controller => 'Root', action => 'form' };
    connect '/form_get2' => { controller => 'Root', action => 'form' };
    connect '/count' => { controller => 'Root', action => 'count' };
    connect '/items/:id' => { 'controller' => 'Item', action => 'view', };
    connect '/bar/:action' => {'controller' => 'Bar',};
};
