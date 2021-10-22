use strict;
use warnings;
use Data::Dumper;
use Set::Scalar;
use DBUtils;

my $info = shift;
my $file = '/tmp/conflict.txt';
my $dbh_offline = $info->{dbh}->{ccdb_offline};
my $dbh_online = $info->{dbh}->{ccdb_online};
my @conflicts = keys(%{$info->{conflicts}});


$info->{message} = '';

if ($info->{tablename} eq "ccdb_paths") {
    my $ReceiveValueHandle = sub {
        my ($id, $dbh) = @_;
        return DBUtils::ReceiveValueFromDatabase($id, $dbh, "ccdb_paths", "pathid", "path");
    };

    my sub GetIdOrInsert {
        my ($path, $dbh) = @_;
        return DBUtils::GetIdOrInsertToDatabase($path, $dbh, "ccdb_paths", "path", "pathid")
    }

    my sub UpdatePathId {
        my ($NewPathId, $ConflictedPath, $dbh) = @_;
        my $UpdateSQL = "update ccdb_paths set pathid = $NewPathId where path = \'$ConflictedPath\'";
        $dbh->do($UpdateSQL);
    }
    
    foreach my $id (@conflicts){
        my $PathFromOffline = $ReceiveValueHandle->($id, $dbh_offline);
        my $PathFromOnline = $ReceiveValueHandle->($id, $dbh_online);
        if($PathFromOffline ne $PathFromOnline) {
            $info->{message} .= "Resolve conflict for path: $PathFromOffline";
            my $NewPathId = GetIdOrInsert($PathFromOffline, $dbh_online);
            UpdatePathId($NewPathId, $PathFromOffline, $dbh_offline);
        }
    }
    
    $info->{tablewinner} = 'ccdb_online';
    my $conflictsAsString = join(",", @conflicts);
    $info->{message} .= "Conflict on ccdb_paths table: $conflictsAsString";
    
    $dbh_offline->do("select ccdb_paths_updated()");
}

if ($info->{tablename} eq "ccdb_contenttype") {
    
    my $ReceiveValueHandle = sub {
        my ($id, $dbh) = @_;
        return DBUtils::ReceiveValueFromDatabase($id, $dbh, "ccdb_contenttype", "contenttypeid", "contenttype");
    };

    my sub GetIdOrInsert {
        my ($ContentType, $dbh) = @_;
        return DBUtils::GetIdOrInsertToDatabase($ContentType, $dbh, "ccdb_contenttype", "contenttype", "contenttypeid")
    }

    my sub UpdateContentTypeId {
        my ($NewContentTypeId, $OldContentTypeId, $dbh) = @_;
        my $UpdateSQL = "update ccdb set contenttype = $NewContentTypeId where contenttype = $OldContentTypeId";
        $dbh->do($UpdateSQL);
        my $UpdateSQL = "update ccdb_contenttype set contenttypeid = $NewContentTypeId where contenttypeid = $OldContentTypeId";
        $dbh->do($UpdateSQL);
    }
    
    foreach my $id (@conflicts){
        my $ContentTypeFromOffline = $ReceiveValueHandle->($id, $dbh_offline);
        my $ContentTypeFromOnline = $ReceiveValueHandle->($id, $dbh_online);
        if($ContentTypeFromOffline ne $ContentTypeFromOnline) {
            my $NewContentTypeId = GetIdOrInsert($ContentTypeFromOffline, $dbh_online);
            UpdateContentTypeId($NewContentTypeId, $id, $dbh_offline);
        }
    }
    $info->{tablewinner} = 'ccdb_online';
    my $conflictsAsString = join(",", @conflicts);
    $info->{message} .= "Conflict on ccdb_contenttype table: $conflictsAsString\n";
}

if ($info->{tablename} eq "ccdb_metadata") {
    my $ReceiveValueHandle = sub {
        my ($id, $dbh) = @_;
        return DBUtils::ReceiveValueFromDatabase($id, $dbh, "ccdb_metadata", "metadataid", "metadatakey");
    };

    my sub GetIdOrInsert {
        my ($ContentType, $dbh) = @_;
        return DBUtils::GetIdOrInsertToDatabase($ContentType, $dbh, "ccdb_metadata", "metadatakey", "metadataid")
    }

    my sub UpdateMetadataId {
        my ($NewMetadataId, $OldMetadataId, $ConflictedContentType, $dbh) = @_;
        my $UpdateSQL = "update ccdb set metadata = delete(metadata || hstore('$NewMetadataId', metadata->'$OldMetadataId'), '$OldMetadataId') where exist(metadata, '$OldMetadataId')";
        $dbh->do($UpdateSQL);
        my $UpdateSQL = "update ccdb_metadata set metadataid = $NewMetadataId where metadataid = $OldMetadataId";
        $dbh->do($UpdateSQL);
    }
    
    foreach my $id (@conflicts){
        my $ContentTypeFromOffline = $ReceiveValueHandle->($id, $dbh_offline);
        my $ContentTypeFromOnline = $ReceiveValueHandle->($id, $dbh_online);
        if($ContentTypeFromOffline ne $ContentTypeFromOnline) {
            my $NewContentTypeId = GetIdOrInsert($ContentTypeFromOffline, $dbh_online);
            UpdateMetadataId($NewContentTypeId, $id, $ContentTypeFromOffline, $dbh_offline);
        }
    }

    $info->{tablewinner} = 'ccdb_offline';
    my @conflicts = keys(%{$info->{conflicts}});
    my $conflictsAsString = join(",", @conflicts);
    $info->{message} = "Conflict on ccdb_metadata table: $conflictsAsString";
}

if ($info->{tablename} eq "ccdb") {    
    $info->{tablewinner} = 'ccdb_offline';
    my @conflicts = keys(%{$info->{conflicts}});
    my $conflictsAsString = join(",", @conflicts);
    $info->{message} = "Conflict on ccdb table: $conflictsAsString";
}

return;
