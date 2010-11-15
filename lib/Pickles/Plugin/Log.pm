package Pickles::Plugin::Log;
use strict;
use Log::Dispatch;

sub install {
    my( $class, $pkg ) = @_;
    my $logger;
    $pkg->add_method( log => sub { 
        my $c = shift;
        $logger ||= do {
            my $config = $c->config->{'Plugin::Log'} || +{
                outputs => [
                    [ 'Screen', min_level => 'debug', stderr => 1, newline => 1 ],
                ],
            };
            Log::Dispatch->new( %{$config} );
        };
        $logger;
    } );
}

1;

__END__
