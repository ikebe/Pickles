
use TinyURL::DB;

register(
    DB => sub {
        my $c = shift;
        my $config = $c->get('config');
        TinyURL::DB->new(@{$config->{datasource}});
    }
);
