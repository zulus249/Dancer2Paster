package MyDb;

use strict;
use warnings;

use DBI;
use Data::UUID;
use Digest::CRC;
use Dancer2;
use File::Slurper 'read_text';

our $created = 0;

sub _connect{
  my $dbh = DBI->connect("dbi:SQLite:dbname=db/entries.db") or
     die $DBI::errstr;
 
  return $dbh;
};

sub create {

    my $db = _connect;

    my $schema = read_text("db/schema.sql");
    $db->do($schema) or die $db->errstr;
    $created = 1;
    
};

sub new
{
    my $class = shift;
    my $self = {};
    
    create unless $created;
    
    bless $self, $class;
    
    return $self;
};

sub add
{
    (my $self, my $ip, my $text) = @_;
    
    my $ctx = Digest::CRC->new(type=>"crc16");
    $ctx->add($text);
    my $id = Data::UUID->new->create_str() . $ctx->hexdigest;
 
    my $dbh = _connect;
    my $sth = $dbh->prepare("insert into entries (id, ip, text) values (?, ?, ?)") or return undef;
    $sth->execute($id, $ip, $text) or return undef;
    $dbh->disconnect;

    return $id;
};

sub getLastEntries
{
    my $self = shift;
    my $dbh = _connect;
    my $sth = $dbh->prepare("select id, ip, date from entries order by date desc limit 10") or return undef;
    $sth->execute or return undef;
    my $res = $sth->fetchall_arrayref();
    # use Data::Dumper;
    # die Dumper($res, $dbh);
    $dbh->disconnect;
    return $res;
};

sub getEntry
{
    (my $self, my $id) = @_;
    my $dbh = _connect;
    my $sth = $dbh->prepare("select id, ip, date, text from entries where id=?") or return undef;
    $sth->execute($id) or return undef;
    my $res = $sth->fetch();
    $dbh->disconnect;
    return $res;
    
}

1;