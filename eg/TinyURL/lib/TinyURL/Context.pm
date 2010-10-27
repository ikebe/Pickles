package TinyURL::Context;

use strict;
use warnings;
use parent 'Pickles::Context';
use TinyURL::DB;

__PACKAGE__->load_plugins(qw(Encode));
__PACKAGE__->register(DB => 
                          TinyURL::DB->new(@{__PACKAGE__->config->{datasource}}));
1;

__END__

