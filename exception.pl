use strict;
use warnings;
use DBUtils;

my $info = shift;
my $dbh_offline = $info->{dbh}->{ccdb_offline};
my $dbh_online = $info->{dbh}->{ccdb_online};

if ($info->{tablename} eq 'ccdb_paths') {

    my $ReceiveValue = sub {
        my ($id, $dbh) = @_;
        return DBUtils::ReceiveValueFromDatabase($id, $dbh, "ccdb_paths", "pathid", "path");
    };

    my $UpdatePathId = sub {
        my ($NewPathId, $OldPathId, $dbh) = @_;
        my $UpdateSQL = "update ccdb set pathid = $NewPathId where pathid = $OldPathId";
        $dbh->do($UpdateSQL);
    };

    my @ConflictsIDsFromMain = keys %{$info -> {deltabin} -> {ccdb_online}};
    my @ConflictsIDsFromStandby = keys %{$info -> {deltabin} -> {ccdb_offline}};

    my %ConflictsPathsFromMain = map { $ReceiveValue->($_, $dbh_online) => $_ } @ConflictsIDsFromMain;
    my %ConflictsPathsFromStandby = map { $ReceiveValue->($_, $dbh_offline) => $_ } @ConflictsIDsFromStandby;

    my @conflictPaths;
    foreach my $item (keys %ConflictsPathsFromMain) {
        push @conflictPaths, $item if grep {  $item eq $_ } keys %ConflictsPathsFromStandby;
    }

    foreach my $item (@conflictPaths) {
        my $NewId = $ConflictsPathsFromMain{$item};
        my $OldId = $ConflictsPathsFromStandby{$item};
        $UpdatePathId->($NewId, $OldId, $dbh_offline);
    }

    my $PathsToRemove = join("','", @conflictPaths);
    my $RemoveConflicts = "delete from ccdb_paths where path in (\'$PathsToRemove\');";
    $dbh_offline->do($RemoveConflicts);

    $dbh_offline->do("select ccdb_paths_updated()");
    
    $info->{retry} = 1;
}

if ($info->{tablename} eq 'ccdb_contenttype') {

    my $ReceiveValue = sub {
        my ($id, $dbh) = @_;
        return DBUtils::ReceiveValueFromDatabase($id, $dbh, "ccdb_contenttype", "contenttypeid", "contenttype");
    };

    my $UpdateContentTypeId = sub {
        my ($NewContentTypeId, $OldContentTypeId, $dbh) = @_;
        my $UpdateSQL = "update ccdb set contenttype = $NewContentTypeId where contenttype = $OldContentTypeId";
        $dbh->do($UpdateSQL);
    };

    my @ConflictsIDsFromMain = keys %{$info -> {deltabin} -> {ccdb_online}};
    my @ConflictsIDsFromStandby = keys %{$info -> {deltabin} -> {ccdb_offline}};

    my %ConflictsContentTypesFromMain = map { $ReceiveValue->($_, $dbh_online) => $_ } @ConflictsIDsFromMain;
    my %ConflictsContentTypesFromStandby = map { $ReceiveValue->($_, $dbh_offline) => $_ } @ConflictsIDsFromStandby;

    my @conflictContentTypes;
    foreach my $item (keys %ConflictsContentTypesFromMain) {
        push @conflictContentTypes, $item if grep {  $item eq $_ } keys %ConflictsContentTypesFromStandby;
    }

    foreach my $item (@conflictContentTypes) {
        my $NewId = $ConflictsContentTypesFromMain{$item};
        my $OldId = $ConflictsContentTypesFromStandby{$item};
        $UpdateContentTypeId->($NewId, $OldId, $dbh_offline);
    }

    my $ValuesToRemove = join("','", @conflictContentTypes);
    my $RemoveConflicts = "delete from ccdb_contenttype where contenttype in (\'$ValuesToRemove\')";
    $dbh_offline->do($RemoveConflicts);
    $info->{retry} = 1;
}

if ($info->{tablename} eq 'ccdb_metadata') {

    my $ReceiveValue = sub {
        my ($id, $dbh) = @_;
        return DBUtils::ReceiveValueFromDatabase($id, $dbh, "ccdb_metadata", "metadataid", "metadatakey");
    };

    my $UpdateMetadataId = sub {
        my ($NewMetadataId, $OldMetadataId, $dbh) = @_;
        my $UpdateSQL = "update ccdb set metadata = delete(metadata || hstore('$NewMetadataId', metadata->'$OldMetadataId'), '$OldMetadataId') where exist(metadata, '$OldMetadataId')";
        $dbh->do($UpdateSQL);
    };

    my @ConflictsIDsFromMain = keys %{$info -> {deltabin} -> {ccdb_online}};
    my @ConflictsIDsFromStandby = keys %{$info -> {deltabin} -> {ccdb_offline}};

    my %ConflictsContentTypesFromMain = map { $ReceiveValue->($_, $dbh_online) => $_ } @ConflictsIDsFromMain;
    my %ConflictsContentTypesFromStandby = map { $ReceiveValue->($_, $dbh_offline) => $_ } @ConflictsIDsFromStandby;

    my @conflictContentTypes;
    foreach my $item (keys %ConflictsContentTypesFromMain) {
        push @conflictContentTypes, $item if grep {  $item eq $_ } keys %ConflictsContentTypesFromStandby;
    }

    foreach my $item (@conflictContentTypes) {
        my $NewId = $ConflictsContentTypesFromMain{$item};
        my $OldId = $ConflictsContentTypesFromStandby{$item};
        $UpdateMetadataId->($NewId, $OldId, $dbh_offline);
    }

    my $ValuesToRemove = join("','", @conflictContentTypes);
    my $RemoveConflicts = "delete from ccdb_metadata where metadatakey in (\'$ValuesToRemove\')";
    $dbh_offline->do($RemoveConflicts);
    $info->{retry} = 1;
}

return;
