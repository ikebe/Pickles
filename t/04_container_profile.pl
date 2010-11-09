
register foo => PicklesTestDummy::A->new;
register bar => sub { PicklesTestDummy::B->new };
register baz => sub { PicklesTestDummy::C->new }, { persistent => 1 };
