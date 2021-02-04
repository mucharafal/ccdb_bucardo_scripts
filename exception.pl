use strict;
use warnings;
use Data::Dumper;

my $info = shift;
my $file = '/tmp/exception.txt';

if ($info->{tablename} eq 'ccdb_paths') {

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

    my $dbh_offline = $info->{dbh}->{ccdb_offline};
    my $dbh_online = $info->{dbh}->{ccdb_online};

    my @ConflictsIDsFromMain = keys $info -> {deltabin} -> {ccdb_online};
    my @ConflictsIDsFromStandby = keys $info -> {deltabin} -> {ccdb_offline};

    my %ConflictsPathsFromMain = map { ReceiveValue($_, $dbh_online) => $_ } @ConflictsIDsFromMain;
    my %ConflictsPathsFromStandby = map { ReceiveValue($_, $dbh_offline) => $_ } @ConflictsIDsFromStandby;

    my @isect;
    foreach my $item (keys %ConflictsPathsFromMain) {
        push @isect, $item if grep {  $item eq $_ } keys %ConflictsPathsFromStandby;
    }

    foreach my $item (@isect) {
        my $NewId = $ConflictsPathsFromMain{$item};
        my $OldId = $ConflictsPathsFromStandby{$item};
        my $RowsToUpdate = ReceiveCCDBRowsToUpdate($OldId, $dbh_offline);
        UpdatePathId($RowsToUpdate, $NewId, $dbh_offline);
    }

    my $PathsToRemove = join("','", @isect);
    my $RemoveConflicts = "delete from ccdb_paths where path in (\'$PathsToRemove\');";

    $dbh_offline->do($RemoveConflicts);

    $info->{retry} = 1;
}
return;
