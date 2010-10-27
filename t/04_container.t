use strict;
use Test::More;

use_ok "Pickles::Container";

sub PicklesTestDummy::A::new { bless {}, $_[0] };
sub PicklesTestDummy::B::new { bless {}, $_[0] };
sub PicklesTestDummy::C::new { bless {}, $_[0] };

Pickles::Container->register( A => PicklesTestDummy::A->new );
Pickles::Container->register( B => sub { PicklesTestDummy::B->new });
Pickles::Container->register( C => sub { PicklesTestDummy::C->new }, { persistent => 1 } );


{
    my ($A, $B, $C);
    {
        my $c = Pickles::Container->new();
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
        my $c = Pickles::Container->new();
        is $A, $c->get('A'), "A is the same as previous A";
        isnt $B, $c->get('B'), "B is NOT the same as previous B";
        is $C, $c->get('C'), "C is the same as previous C";
    }
        
}


done_testing;