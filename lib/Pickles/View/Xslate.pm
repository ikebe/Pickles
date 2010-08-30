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
    my $config = $self->merge_config( $c );
    $tx ||= Text::Xslate->new(
        path => [
            $c->config->path_to('view'),
            $c->config->path_to('view', 'inc'),
        ],
        %{$config},
    );
    my $template = $c->stash->{template};
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
