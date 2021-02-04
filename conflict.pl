use strict;
use warnings;
use Data::Dumper;
use Set::Scalar;

my $info = shift;
my $file = '/tmp/conflict.txt';

if ($info->{tablename} eq "ccdb_paths") {
    sub ReceiveValue {
        my ($id, $dbh) = @_;
        my $SQL = "select path from ccdb_paths where pathid = ?;";
        my $sth = $dbh->prepare($SQL);
        $sth->execute( $id );
        while ( my @row = $sth->fetchrow_array ) {
            return $row[0];
        }
    }

    sub ReceiveCCDBRowsToUpdate {
        my ($id, $dbh) = @_;
        my $SQL = "select id from ccdb where pathid = ?";
        my $sth = $dbh->prepare($SQL);
        $sth->execute( $id );
        return $sth->fetchall_arrayref;
    }

    sub GetIdOrInsert {
        my ($path, $dbh) = @_;
        my $InsertSQL = "insert into ccdb_paths(path) values (?);";
        my $GetSQL = "select pathid from ccdb_paths where path = ?;";
        my $sth = $dbh->prepare($GetSQL);
        $sth->execute( $path );
        while ( my @IdRow = $sth->fetchrow_array ) {
            return $IdRow[0];
        }
        $sth = $dbh->prepare($InsertSQL);
        $sth->execute( $path );
        my $sth = $dbh->prepare($GetSQL);
        $sth->execute( $path );
        while ( my @id = $sth->fetchrow_array ) {
            return $id[0];
        }
    }

    sub UpdatePathId {
        my ($IdRowsToUpdateRaw, $NewPathId, $dbh) = @_;
        if (scalar @$IdRowsToUpdateRaw > 0) {
            my @IdRowsToUpdate = ();
            foreach my $array (@$IdRowsToUpdateRaw) {
                push @IdRowsToUpdate, (${$array}[0]);
            }
            my $Ids = join("','", @IdRowsToUpdate);
            my $UpdateSQL = "update ccdb set pathid = $NewPathId where id in (\'$Ids\');";
            $dbh->do($UpdateSQL);
        }
    }

    my @conflicts = keys $info->{conflicts};
    my $dbh_offline = $info->{dbh}->{ccdb_offline};
    my $dbh_online = $info->{dbh}->{ccdb_online};
    my %to_update = ();
    foreach my $i (@conflicts){
        my $Path = ReceiveValue($i, $dbh_offline);
        my $ValuesToUpdateForPath = ReceiveCCDBRowsToUpdate($i, $dbh_offline);
        $to_update{$Path} = $ValuesToUpdateForPath;
    }
    foreach my $path (keys %to_update) {
        my $NewPathId = GetIdOrInsert($path, $dbh_online);
        UpdatePathId($to_update{$path}, $NewPathId, $dbh_offline);
    }
    my $GetSQL = "select * from ccdb_paths;";
    my $sth = $dbh_offline->prepare($GetSQL);
    $sth->execute();
}
$info->{tablewinner} = 'ccdb_online';
return;
