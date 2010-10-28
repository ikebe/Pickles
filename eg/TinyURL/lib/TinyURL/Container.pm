package TinyURL::Container;

use strict;
use warnings;
use parent 'Pickles::Container';
use TinyURL::DB;
use TinyURL::Config;

my $config = TinyURL::Config->new;
__PACKAGE__->register(DB => TinyURL::DB->new(@{$config->{datasource}}));

1;

__END__

