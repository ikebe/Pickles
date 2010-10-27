package TinyURL::DB;
use strict;
use DBI;
use TinyURL::Config;
use String::Random;

sub new {
    my( $class, @datasource ) = @_;
    my $dbh = DBI->connect( @datasource, {
        RaiseError => 1,
    } ) or die $DBI::errstr;
    my $self = bless {
        _dbh => $dbh,
    }, $class;
    $self;
}
sub dbh { shift->{_dbh}; }

sub add {
    my( $self, $url ) = @_;
    my $rv = $self->dbh->selectall_arrayref(
        'SELECT * FROM url WHERE url = ?',
        { Slice => +{} },
        $url,
    );
    return $rv->[0]->{id} if @$rv;
    my $r = String::Random->new;
    my $id = $r->randregex('[a-zA-Z0-9_]{6}');
    $self->dbh->do(
        'INSERT INTO url (id, url) VALUES(?, ?)',
        undef,
        $id, $url
    );
    $id;
}

sub lookup {
    my( $self, $id ) = @_;
    my $rv = $self->dbh->selectall_arrayref(
        'SELECT * FROM url WHERE id = ?',
        { Slice => +{} },
        $id,
    );
    return $rv->[0]->{url} if @$rv;
}


1;

__END__
