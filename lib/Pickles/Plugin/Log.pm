package Pickles::Plugin::Log;
use strict;
use Log::Dispatch;

sub install {
    my( $class, $pkg ) = @_;
    my $config = $pkg->config->{'Plugin::Log'} || +{
        outputs => [
            [ 'Screen', min_level => 'debug', stderr => 1, newline => 1 ],
        ],
    };
    my $logger = Log::Dispatch->new( %{$config} );
    $pkg->add_method( log => sub { $logger } );
}

1;

__END__
