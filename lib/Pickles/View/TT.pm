package Pickles::View::TT;
use strict;
use base qw(Pickles::View);
use Template;
use Data::Dumper;

my $tt;

__PACKAGE__->config( TEMPLATE_EXTENSION => '.html' );
sub new {
    my $class = shift;
    my $self = bless {}, $class;
    $self;
}

sub render {
    my( $self, $c ) = @_;
    my $config = $self->merge_config( $c );
    $tt ||= Template->new({
        ENCODING => 'utf8',
        UNICODE => 1,
        ABSOLUTE => 1,
        INCLUDE_PATH => [
            $c->config->path_to('view'),
            $c->config->path_to('view', 'inc'),
        ],
        %{$config},
    });
    my $template = $c->stash->{template};
    unless ( $template =~ /$config->{TEMPLATE_EXTENSION}$/ ) {
        $template .= $config->{TEMPLATE_EXTENSION};
    }
    $tt->process( $template, {
        %{$c->stash},
        c => $c,
    }, \my $output ) or die $tt->error;
    return $output;
}

1;

__END__
