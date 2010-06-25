package Pickles::View::MicroTemplate;
use strict;
use base qw(Pickles::View);
use Text::MicroTemplate::Extended;

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
        extension => '.html',
        include_path => [
            $c->config->path_to('view'),
        ],
        %{$config},
        template_args => \%args,
    );
    my $template = $c->stash->{template};
    warn $template;
    $mt->render( $template );
}

1;

__END__
