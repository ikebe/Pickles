package Pickles::View::Xslate;
use strict;
use base qw(Pickles::View);
use Text::Xslate;

my $tx;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub render {
    my( $self, $c ) = @_;
    my $tx = $self->{xslate};
    if (! $tx) {
        my $config = $self->merge_config( $c );
        $tx = $self->{xslate} = Text::Xslate->new(
            path => [
                $c->config->path_to('view'),
                $c->config->path_to('view', 'inc'),
            ],
            %{$config},
        );
    }
    my $template = $c->stash->{'VIEW_TEMPLATE'};
    my $suffix = $tx->{suffix};
    unless ( $template =~ /$suffix$/ ) {
        $template .= $suffix;
    }
    my %vars = (
        %{$c->stash},
        c => $c,
    );
    my $output = $tx->render( $template, \%vars );
    return $output;
}

1;

__END__
