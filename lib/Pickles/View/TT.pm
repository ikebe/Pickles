package Pickles::View::TT;
use strict;
use base qw(Pickles::View);
use Template;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub render {
    my( $self, $c ) = @_;
    my $config = $c->config->{'View::TT'} || {};
    my $tt = Template->new({
        ENCODING => 'utf8',
        UNICODE => 1,
        ABSOLUTE => 1,
        %{$config},
    });
    my $template = $c->stash->{template} || $c->template_filename;
    $tt->process( $template, {
        %{$c->stash},
        c => $c,
    }, \my $output ) or die $tt->error;
    return $output;
}

1;

__END__
