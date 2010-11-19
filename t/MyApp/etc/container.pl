
use MyApp::Model::Test;

register( model_obj => MyApp::Model::Test->new );
register( InitValue => sub { bless {}, 'MyApp::ControllerValue'; } );
