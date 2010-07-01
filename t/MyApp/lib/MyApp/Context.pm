package MyApp::Context;

use strict;
use warnings;
use parent 'Pickles::Context';
use MyApp::Model::Test;

__PACKAGE__->load_plugins(qw(Encode +MyApp::Plugin::Test));
__PACKAGE__->register(model_obj => MyApp::Model::Test->new);


1;

__END__

