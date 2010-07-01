package Pickles::View::MicroTemplate;
use strict;
use base qw(Pickles::View);
use Text::MicroTemplate::Extended;
use Encode;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub render {
    my( $self, $c ) = @_;
    my $config = $c->config->{'View::MicroTemplate'} || {};
    my %args = (
        %{$c->stash},
        c => $c,
    );
    my $mt = Text::MicroTemplate::Extended->new(
        extension => '',
        include_path => [
            $c->config->path_to('view'),
            $c->config->path_to('view', 'inc'),
        ],
        %{$config},
        template_args => \%args,
    );
    my $template = $c->stash->{template};
    # $body is-a Text::MicroTemplate::EncodedString
    my $body = $mt->render( $template );
    (ref $body && $body->can('as_string')) ? $body->as_string : $body;
}

1;

__END__
