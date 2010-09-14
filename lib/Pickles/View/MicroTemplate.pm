package Pickles::View::MicroTemplate;
use strict;
use base qw(Pickles::View);
use Text::MicroTemplate::Extended;

__PACKAGE__->config( extension => '.mt' );

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub render {
    my( $self, $c ) = @_;
    my $config = $self->merge_config( $c );
    my %args = (
        %{$c->stash},
        c => $c,
    );
    my $mt = Text::MicroTemplate::Extended->new(
        include_path => [
            $c->config->path_to('view'),
            $c->config->path_to('view', 'inc'),
        ],
        %{$config},
        template_args => \%args,
    );
    my $template = $c->stash->{'VIEW_TEMPLATE'};
    # $body is-a Text::MicroTemplate::EncodedString
    my $body = $mt->render( $template );
    (ref $body && $body->can('as_string')) ? $body->as_string : $body;
}

1;

__END__
