use strict;
use Test::More;

use_ok "Pickles::Config";
use_ok "Pickles::Container";

sub PicklesTestDummy::A::new { bless {}, $_[0] };
sub PicklesTestDummy::B::new { bless {}, $_[0] };
sub PicklesTestDummy::C::new { bless {}, $_[0] };


{
    my $c = Pickles::Container->new();
    $c->register( A => PicklesTestDummy::A->new );
    $c->register( B => sub { PicklesTestDummy::B->new });
    $c->register( C => sub { PicklesTestDummy::C->new }, { persistent => 1 } );

    my ($A, $B, $C);
    {
        my $scope = $c->new_scope();
        $A = $c->get('A');
        $B = $c->get('B');
        $C = $c->get('C');

        ok $A, "A is defined";
        isa_ok $A, "PicklesTestDummy::A";
        ok $B, "B is defined";
        isa_ok $B, "PicklesTestDummy::B";
        ok $C, "C is defined";
        isa_ok $C, "PicklesTestDummy::C";
    }
        
    {
        my $scope = $c->new_scope();
        is $A, $c->get('A'), "A is the same as previous A";
        isnt $B, $c->get('B'), "B is NOT the same as previous B";
        is $C, $c->get('C'), "C is the same as previous C";
    }
        
}

{
    my $c = Pickles::Container->new();
    $c->register( config => Pickles::Config->new( home => "." ) );
    $c->load( "t/04_container_profile.pl" );

    my $A = $c->get('foo');
    my $B = $c->get('bar');
    my $C = $c->get('baz');

    ok $A, "A is defined";
    isa_ok $A, "PicklesTestDummy::A";
    ok $B, "B is defined";
    isa_ok $B, "PicklesTestDummy::B";
    ok $C, "C is defined";
    isa_ok $C, "PicklesTestDummy::C";
}

done_testing;