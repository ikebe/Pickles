my $external = load_file( 't/02_config_quux_ext.pl' );
return +{
    quux => 1,
    %$external
};