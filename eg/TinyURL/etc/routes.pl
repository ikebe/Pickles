
router {
    connect '/' => { controller => 'Root', action => 'index' };
    connect '/add' => { controller => 'Root', action => 'add', };
    connect '/:id' => { controller => 'Root', action => 'go' };
};