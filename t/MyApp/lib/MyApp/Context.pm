package MyApp::Context;

use strict;
use warnings;
use parent 'Pickles::Context';
use MyApp::Model::Test;

# #__PACKAGE__->load_plugins(qw(Encode +MyApp::Plugin::Test));
# __PACKAGE__->register(model_obj => MyApp::Model::Test->new);
# sub MyApp::ControllerValue::new { bless {}, $_[0] };

# __PACKAGE__->register( InitValue => sub {
#     MyApp::ControllerValue->new;
# });

__PACKAGE__->add_trigger( init => sub {
    my( $c ) = @_;
    
    if ($c->req->path=~m|^/api|) {
        $c->stash->{skip_csrf_check}++;
    }
} );

1;

__END__

