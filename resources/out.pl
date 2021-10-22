{
  'syncname' => 'sync_online_and_offline',
  'targetname' => '',
  'error' => '',
  'sourcename' => undef,
  'rellist' => [
    {
      'oid' => '17343',
      'columnlist' => 'path',
      'makedelta' => '',
      'db' => 'ccdb_online',
      'binarypkey' => {
        '0' => 0
      },
      'id' => 1,
      'delta_bypass_min' => undef,
      'columnhash' => {
        'pathid' => {
          'attname' => 'pathid',
          'def' => 'nextval(\'public.ccdb_paths_pathid_seq\'::regclass)',
          'realattnum' => 1,
          'attnum' => 1,
          'attnotnull' => 1,
          'atttypid' => 23,
          'ftype' => 'integer',
          'atthasdef' => 1,
          'qattname' => 'pathid'
        },
        'path' => {
          'atthasdef' => 0,
          'qattname' => 'path',
          'ftype' => 'text',
          'atttypid' => 25,
          'order' => 1,
          'attnum' => 2,
          'attnotnull' => 1,
          'def' => undef,
          'realattnum' => 2,
          'attname' => 'path'
        }
      },
      'pkey' => [
        'pathid'
      ],
      'deltatable' => 'delta_public_ccdb_paths',
      'safeschema' => 'public',
      'hasbinarypk' => 0,
      'numpkcols' => 1,
      'safecols' => [
        'path'
      ],
      'pkeytype' => [
        'integer'
      ],
      'safetable' => 'ccdb_paths',
      'pklist' => '"pathid"',
      'tcolumns' => {
        'SELECT *' => [
          'pathid',
          'path'
        ]
      },
      'autokick' => undef,
      'cols' => [
        'path'
      ],
      'code_exception' => [
        {
          'about' => '?',
          'getdbh' => 1,
          'priority' => 0,
          'whenrun' => 'exception',
          'coderef' => sub { "DUMMY" },
          'active' => 1,
          'src_code' => 'use strict;
use warnings;
use Data::Dumper;

my $info = shift;
my $file = \'/tmp/exception.txt\';

if ($info->{tablename} eq \'ccdb_paths\') {

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
            my $Ids = join("\',\'", @IdRowsToUpdate);
            my $UpdateSQL = "update ccdb set pathid = $NewPathId where id in (\\\'$Ids\\\');";
            $dbh->do($UpdateSQL);
        }
    }

    my $dbh_offline = $info->{dbh}->{ccdb_offline};
    my $dbh_online = $info->{dbh}->{ccdb_online};

    my @ConflictsIDsFromMain = keys %{$info -> {deltabin} -> {ccdb_online}};
    my @ConflictsIDsFromStandby = keys %{$info -> {deltabin} -> {ccdb_offline}};

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
        UpdatePathId($RowsToUpdate, $NewId, $dbh_online);
    }

    my $PathsToRemove = join("\',\'", @isect);
    my $RemoveConflicts = "delete from ccdb_paths where path in (\\\'$PathsToRemove\\\');";

    $dbh_offline->do($RemoveConflicts);

    $info->{retry} = 1;
}

if ($info->{tablename} eq \'ccdb_contenttype\') {

    sub ReceiveValue {
        my ($id, $dbh) = @_;
        my $SQL = "select contenttype from ccdb_contenttype where contenttypeid = ?;";
        my $sth = $dbh->prepare($SQL);
        $sth->execute( $id );
        while ( my @row = $sth->fetchrow_array ) {
            return $row[0];
        }
    }

    sub ReceiveCCDBRowsToUpdate {
        my ($id, $dbh) = @_;
        my $SQL = "select id from ccdb where contenttype = ?";
        my $sth = $dbh->prepare($SQL);
        $sth->execute( $id );
        return $sth->fetchall_arrayref;
    }

    sub UpdateContentTypeId {
        my ($IdRowsToUpdateRaw, $NewContentTypeId, $dbh) = @_;
        if (scalar @$IdRowsToUpdateRaw > 0) {
            my @IdRowsToUpdate = ();
            foreach my $array (@$IdRowsToUpdateRaw) {
                push @IdRowsToUpdate, (${$array}[0]);
            }
            my $Ids = join("\',\'", @IdRowsToUpdate);
            my $UpdateSQL = "update ccdb set contenttype = $NewContentTypeId where id in (\\\'$Ids\\\');";
            $dbh->do($UpdateSQL);
        }
    }

    my $dbh_offline = $info->{dbh}->{ccdb_offline};
    my $dbh_online = $info->{dbh}->{ccdb_online};

    my @ConflictsIDsFromMain = keys %{$info -> {deltabin} -> {ccdb_online}};
    my @ConflictsIDsFromStandby = keys %{$info -> {deltabin} -> {ccdb_offline}};

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
        UpdateContentTypeId($RowsToUpdate, $NewId, $dbh_offline);
        UpdateContentTypeId($RowsToUpdate, $NewId, $dbh_online);
    }

    my $ContentTypesToRemove = join("\',\'", @isect);
    my $RemoveConflicts = "delete from ccdb_contenttype where contenttype in (\\\'$ContentTypesToRemove\\\');";

    $dbh_offline->do($RemoveConflicts);

    $info->{retry} = 1;
}

return;
',
          'status' => 'active',
          'name' => 'exception',
          'goat' => 0,
          'id' => 1
        }
      ],
      'stagetable' => 'stage_public_ccdb_paths',
      'vacuum_after_copy' => 1,
      'conflict_strategy' => 'bucardo_abort',
      'qpkey' => [
        'pathid'
      ],
      'safecolumnlist' => 'path',
      'has_delta' => 0,
      'safeschemaliteral' => '\'public\'',
      'schemaname' => 'public',
      'rebuild_index' => 0,
      'analyze_after_copy' => 1,
      'tracktable' => 'track_public_ccdb_paths',
      'newcols' => {
        'sync_online_and_offline' => {
          'ccdb_online' => '',
          'ccdb_offline' => ''
        }
      },
      'safetableliteral' => '\'ccdb_paths\'',
      'strict_checking' => 1,
      'delta_bypass' => 0,
      'reltype' => 'table',
      'delta_bypass_count' => undef,
      'has_exception_code' => 1,
      'newname' => {
        'sync_online_and_offline' => {
          'ccdb_offline' => 'public.ccdb_paths',
          'ccdb_online' => 'public.ccdb_paths'
        }
      },
      'ghost' => 0,
      'tablename' => 'ccdb_paths',
      'cdate' => '2021-03-11 14:51:15.157718+00',
      'makername' => 'public_ccdb_paths',
      'code_before_sync' => [
        {
          'about' => '?',
          'getdbh' => 1,
          'priority' => 0,
          'whenrun' => 'before_sync',
          'coderef' => sub { "DUMMY" },
          'src_code' => 'use DBUtils;
use strict;
use warnings;
use Data::Dumper;

my $info = shift;
# my $dbh_offline = $info->{dbh}->{ccdb_offline};
# my $dbh_online = $info->{dbh}->{ccdb_online};

# @ccdb::affectedRows = [];

# my $responseWithIds = DBUtils::ReceiveValuesFromDatabase($dbh_offline, "bucardo.delta_public_ccdb", "id");
# foreach my $id (@{$responseWithIds}) {
#     push(@ccdb::affectedRows, @{$id}[0]);
# }

$info->{message} = Dumper $info;',
          'active' => 1,
          'status' => 'active',
          'name' => 'before_sync',
          'goat' => 0,
          'id' => 3
        }
      ],
      'delta_bypass_percent' => undef,
      'code_conflict' => [
        {
          'getdbh' => 1,
          'priority' => 0,
          'about' => '?',
          'whenrun' => 'conflict',
          'src_code' => 'use strict;
use warnings;
use Data::Dumper;
use Set::Scalar;
use DBUtils;

my $info = shift;
my $file = \'/tmp/conflict.txt\';
my $dbh_offline = $info->{dbh}->{ccdb_offline};
my $dbh_online = $info->{dbh}->{ccdb_online};
my @conflicts = keys(%{$info->{conflicts}});

$info->{message} = \'\';

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
        my $UpdateSQL = "update ccdb_paths set pathid = $NewPathId where path = \\\'$ConflictedPath\\\';";
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
    
    $info->{tablewinner} = \'ccdb_online\';
    my $conflictsAsString = join(",", @conflicts);
    $info->{message} .= "Conflict on ccdb_paths table: $conflictsAsString";
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
        my ($NewContentTypeId, $OldContentTypeId, $ConflictedContentType, $dbh) = @_;
        my $UpdateSQL = "update ccdb set contenttype = $NewContentTypeId where contenttype = $OldContentTypeId;";
        $dbh->do($UpdateSQL);
        $UpdateSQL = "update ccdb_contenttype set contenttypeid = $NewContentTypeId where contenttype = \\\'$ConflictedContentType\\\';";
        $dbh->do($UpdateSQL);
        my $sampleIdAfter = DBUtils::ReceiveValueFromDatabase($NewContentTypeId, $dbh, "ccdb", "contenttype", "id");
        $info->{message} .= $UpdateSQL.$sampleIdAfter;
    }
    
    foreach my $id (@conflicts){
        my $ContentTypeFromOffline = $ReceiveValueHandle->($id, $dbh_offline);
        my $ContentTypeFromOnline = $ReceiveValueHandle->($id, $dbh_online);
        if($ContentTypeFromOffline ne $ContentTypeFromOnline) {
            my $NewContentTypeId = GetIdOrInsert($ContentTypeFromOffline, $dbh_online);
            my $sampleId = DBUtils::ReceiveValueFromDatabase($id, $dbh_offline, "ccdb", "contenttype", "id");
            UpdateContentTypeId($NewContentTypeId, $id, $ContentTypeFromOffline, $dbh_offline);
            $info->{message} .= "Resolve conflict for content: $ContentTypeFromOffline vs $ContentTypeFromOnline by change id from $id to $NewContentTypeId; Sample id: $sampleId\\n";
        }
    }
    $info->{tablewinner} = \'ccdb_online\';
    my $conflictsAsString = join(",", @conflicts);
    # my $shiftDump = Dumper $info;
    $info->{message} .= "Conflict on ccdb_contenttype table: $conflictsAsString\\n";
    foreach my $affectedId (@ccdb::affectedRows) {
        $info->{message} .= "$affectedId,";
    }
}

if ($info->{tablename} eq "ccdb") {
    
    $info->{tablewinner} = \'ccdb_offline\';
    my @conflicts = keys(%{$info->{conflicts}});
    my $conflictsAsString = join(",", @conflicts);
    $info->{message} = "Conflict on ccdb table: $conflictsAsString";
}

if ($info->{tablename} eq "ccdb_metadata") {
    
    $info->{tablewinner} = \'ccdb_offline\';
    my @conflicts = keys(%{$info->{conflicts}});
    my $conflictsAsString = join(",", @conflicts);
    $info->{message} = "Conflict on ccdb_metadata table: $conflictsAsString";
}
return;
',
          'active' => 1,
          'coderef' => sub { "DUMMY" },
          'name' => 'conflict',
          'goat' => 0,
          'id' => 2,
          'status' => 'active'
        }
      ]
    },
    {
      'delta_bypass_count' => undef,
      'has_exception_code' => 1,
      'newname' => {
        'sync_online_and_offline' => {
          'ccdb_online' => 'public.ccdb',
          'ccdb_offline' => 'public.ccdb'
        }
      },
      'ghost' => 0,
      'tablename' => 'ccdb',
      'cdate' => '2021-03-11 14:51:15.157718+00',
      'makername' => 'public_ccdb',
      'code_before_sync' => [
        $BUCARDO1->{'rellist'}[0]{'code_before_sync'}[0]
      ],
      'delta_bypass_percent' => undef,
      'code_conflict' => [
        $BUCARDO1->{'rellist'}[0]{'code_conflict'}[0]
      ],
      'conflict_strategy' => 'bucardo_abort',
      'qpkey' => [
        'id'
      ],
      'safecolumnlist' => 'pathid,validity,createtime,replicas,size,md5,filename,contenttype,uploadedfrom,initialvalidity,metadata,lastmodified',
      'has_delta' => 0,
      'safeschemaliteral' => '\'public\'',
      'schemaname' => 'public',
      'rebuild_index' => 0,
      'analyze_after_copy' => 1,
      'tracktable' => 'track_public_ccdb',
      'newcols' => {
        'sync_online_and_offline' => {
          'ccdb_online' => '',
          'ccdb_offline' => ''
        }
      },
      'safetableliteral' => '\'ccdb\'',
      'strict_checking' => 1,
      'delta_bypass' => 0,
      'reltype' => 'table',
      'hasbinarypk' => 0,
      'numpkcols' => 1,
      'safecols' => [
        'pathid',
        'validity',
        'createtime',
        'replicas',
        'size',
        'md5',
        'filename',
        'contenttype',
        'uploadedfrom',
        'initialvalidity',
        'metadata',
        'lastmodified'
      ],
      'pkeytype' => [
        'uuid'
      ],
      'safetable' => 'ccdb',
      'pklist' => '"id"',
      'autokick' => undef,
      'tcolumns' => {
        'SELECT *' => [
          'id',
          'pathid',
          'validity',
          'createtime',
          'replicas',
          'size',
          'md5',
          'filename',
          'contenttype',
          'uploadedfrom',
          'initialvalidity',
          'metadata',
          'lastmodified'
        ]
      },
      'cols' => [
        'pathid',
        'validity',
        'createtime',
        'replicas',
        'size',
        'md5',
        'filename',
        'contenttype',
        'uploadedfrom',
        'initialvalidity',
        'metadata',
        'lastmodified'
      ],
      'code_exception' => [
        $BUCARDO1->{'rellist'}[0]{'code_exception'}[0]
      ],
      'stagetable' => 'stage_public_ccdb',
      'vacuum_after_copy' => 1,
      'columnlist' => 'pathid,validity,createtime,replicas,size,md5,filename,contenttype,uploadedfrom,initialvalidity,metadata,lastmodified',
      'makedelta' => '',
      'oid' => '17367',
      'db' => 'ccdb_online',
      'binarypkey' => {
        '0' => 0
      },
      'id' => 2,
      'columnhash' => {
        'pathid' => {
          'order' => 1,
          'attnotnull' => 1,
          'attnum' => 2,
          'def' => undef,
          'realattnum' => 2,
          'attname' => 'pathid',
          'atthasdef' => 0,
          'qattname' => 'pathid',
          'ftype' => 'integer',
          'atttypid' => 23
        },
        'createtime' => {
          'order' => 3,
          'attnum' => 4,
          'attnotnull' => 1,
          'realattnum' => 4,
          'def' => undef,
          'attname' => 'createtime',
          'atthasdef' => 0,
          'qattname' => 'createtime',
          'ftype' => 'bigint',
          'atttypid' => 20
        },
        'replicas' => {
          'atthasdef' => 0,
          'qattname' => 'replicas',
          'atttypid' => 1007,
          'ftype' => 'integer[]',
          'attnum' => 5,
          'attnotnull' => 0,
          'order' => 4,
          'attname' => 'replicas',
          'def' => undef,
          'realattnum' => 5
        },
        'md5' => {
          'atttypid' => 2950,
          'ftype' => 'uuid',
          'atthasdef' => 0,
          'qattname' => 'md5',
          'attname' => 'md5',
          'realattnum' => 7,
          'def' => undef,
          'attnum' => 7,
          'attnotnull' => 0,
          'order' => 6
        },
        'metadata' => {
          'order' => 11,
          'attnotnull' => 0,
          'attnum' => 12,
          'realattnum' => 12,
          'def' => undef,
          'attname' => 'metadata',
          'qattname' => 'metadata',
          'atthasdef' => 0,
          'ftype' => 'public.hstore',
          'atttypid' => 17215
        },
        'contenttype' => {
          'qattname' => 'contenttype',
          'atthasdef' => 0,
          'atttypid' => 23,
          'ftype' => 'integer',
          'attnotnull' => 0,
          'attnum' => 9,
          'order' => 8,
          'attname' => 'contenttype',
          'def' => undef,
          'realattnum' => 9
        },
        'id' => {
          'atttypid' => 2950,
          'ftype' => 'uuid',
          'atthasdef' => 0,
          'qattname' => 'id',
          'attname' => 'id',
          'realattnum' => 1,
          'def' => undef,
          'attnotnull' => 1,
          'attnum' => 1
        },
        'uploadedfrom' => {
          'qattname' => 'uploadedfrom',
          'atthasdef' => 0,
          'atttypid' => 869,
          'ftype' => 'inet',
          'attnum' => 10,
          'attnotnull' => 0,
          'order' => 9,
          'attname' => 'uploadedfrom',
          'def' => undef,
          'realattnum' => 10
        },
        'filename' => {
          'attname' => 'filename',
          'realattnum' => 8,
          'def' => undef,
          'attnum' => 8,
          'attnotnull' => 0,
          'order' => 7,
          'atttypid' => 25,
          'ftype' => 'text',
          'atthasdef' => 0,
          'qattname' => 'filename'
        },
        'lastmodified' => {
          'attname' => 'lastmodified',
          'def' => undef,
          'realattnum' => 13,
          'attnum' => 13,
          'attnotnull' => 0,
          'order' => 12,
          'atttypid' => 20,
          'ftype' => 'bigint',
          'atthasdef' => 0,
          'qattname' => 'lastmodified'
        },
        'initialvalidity' => {
          'attname' => 'initialvalidity',
          'def' => undef,
          'realattnum' => 11,
          'attnotnull' => 0,
          'attnum' => 11,
          'order' => 10,
          'atttypid' => 20,
          'ftype' => 'bigint',
          'atthasdef' => 0,
          'qattname' => 'initialvalidity'
        },
        'size' => {
          'ftype' => 'bigint',
          'atttypid' => 20,
          'atthasdef' => 0,
          'qattname' => 'size',
          'realattnum' => 6,
          'def' => undef,
          'attname' => 'size',
          'order' => 5,
          'attnotnull' => 0,
          'attnum' => 6
        },
        'validity' => {
          'atttypid' => 3908,
          'ftype' => 'tsrange',
          'atthasdef' => 0,
          'qattname' => 'validity',
          'attname' => 'validity',
          'realattnum' => 3,
          'def' => undef,
          'attnotnull' => 0,
          'attnum' => 3,
          'order' => 2
        }
      },
      'delta_bypass_min' => undef,
      'pkey' => [
        'id'
      ],
      'deltatable' => 'delta_public_ccdb',
      'safeschema' => 'public'
    },
    {
      'conflict_strategy' => 'bucardo_abort',
      'qpkey' => [
        'contenttypeid'
      ],
      'schemaname' => 'public',
      'safecolumnlist' => 'contenttype',
      'safeschemaliteral' => '\'public\'',
      'has_delta' => 0,
      'newcols' => {
        'sync_online_and_offline' => {
          'ccdb_online' => '',
          'ccdb_offline' => ''
        }
      },
      'tracktable' => 'track_public_ccdb_contenttype',
      'analyze_after_copy' => 1,
      'rebuild_index' => 0,
      'delta_bypass' => 0,
      'reltype' => 'table',
      'strict_checking' => 1,
      'safetableliteral' => '\'ccdb_contenttype\'',
      'has_exception_code' => 1,
      'delta_bypass_count' => undef,
      'tablename' => 'ccdb_contenttype',
      'ghost' => 0,
      'newname' => {
        'sync_online_and_offline' => {
          'ccdb_offline' => 'public.ccdb_contenttype',
          'ccdb_online' => 'public.ccdb_contenttype'
        }
      },
      'code_conflict' => [
        $BUCARDO1->{'rellist'}[0]{'code_conflict'}[0]
      ],
      'delta_bypass_percent' => undef,
      'code_before_sync' => [
        $BUCARDO1->{'rellist'}[0]{'code_before_sync'}[0]
      ],
      'makername' => 'public_ccdb_contenttype',
      'cdate' => '2021-03-11 14:51:15.157718+00',
      'columnlist' => 'contenttype',
      'makedelta' => '',
      'oid' => '17356',
      'binarypkey' => {
        '0' => 0
      },
      'db' => 'ccdb_online',
      'id' => 3,
      'columnhash' => {
        'contenttypeid' => {
          'realattnum' => 1,
          'def' => 'nextval(\'public.ccdb_contenttype_contenttypeid_seq\'::regclass)',
          'attname' => 'contenttypeid',
          'attnotnull' => 1,
          'attnum' => 1,
          'ftype' => 'integer',
          'atttypid' => 23,
          'qattname' => 'contenttypeid',
          'atthasdef' => 1
        },
        'contenttype' => {
          'atthasdef' => 0,
          'qattname' => 'contenttype',
          'ftype' => 'text',
          'atttypid' => 25,
          'order' => 1,
          'attnum' => 2,
          'attnotnull' => 1,
          'def' => undef,
          'realattnum' => 2,
          'attname' => 'contenttype'
        }
      },
      'delta_bypass_min' => undef,
      'safeschema' => 'public',
      'deltatable' => 'delta_public_ccdb_contenttype',
      'pkey' => [
        'contenttypeid'
      ],
      'hasbinarypk' => 0,
      'numpkcols' => 1,
      'safecols' => [
        'contenttype'
      ],
      'cols' => [
        'contenttype'
      ],
      'safetable' => 'ccdb_contenttype',
      'pkeytype' => [
        'integer'
      ],
      'autokick' => undef,
      'tcolumns' => {
        'SELECT *' => [
          'contenttypeid',
          'contenttype'
        ]
      },
      'pklist' => '"contenttypeid"',
      'code_exception' => [
        $BUCARDO1->{'rellist'}[0]{'code_exception'}[0]
      ],
      'stagetable' => 'stage_public_ccdb_contenttype',
      'vacuum_after_copy' => 1
    },
    {
      'qpkey' => [
        'metadataid'
      ],
      'conflict_strategy' => 'bucardo_abort',
      'has_delta' => 0,
      'safeschemaliteral' => '\'public\'',
      'safecolumnlist' => 'metadatakey',
      'schemaname' => 'public',
      'rebuild_index' => 0,
      'analyze_after_copy' => 1,
      'tracktable' => 'track_public_ccdb_metadata',
      'newcols' => {
        'sync_online_and_offline' => {
          'ccdb_offline' => '',
          'ccdb_online' => ''
        }
      },
      'strict_checking' => 1,
      'safetableliteral' => '\'ccdb_metadata\'',
      'reltype' => 'table',
      'delta_bypass' => 0,
      'delta_bypass_count' => undef,
      'has_exception_code' => 1,
      'newname' => {
        'sync_online_and_offline' => {
          'ccdb_offline' => 'public.ccdb_metadata',
          'ccdb_online' => 'public.ccdb_metadata'
        }
      },
      'ghost' => 0,
      'tablename' => 'ccdb_metadata',
      'makername' => 'public_ccdb_metadata',
      'cdate' => '2021-03-11 14:51:15.157718+00',
      'code_before_sync' => [
        $BUCARDO1->{'rellist'}[0]{'code_before_sync'}[0]
      ],
      'delta_bypass_percent' => undef,
      'code_conflict' => [
        $BUCARDO1->{'rellist'}[0]{'code_conflict'}[0]
      ],
      'columnlist' => 'metadatakey',
      'oid' => '17389',
      'makedelta' => '',
      'db' => 'ccdb_online',
      'binarypkey' => {
        '0' => 0
      },
      'delta_bypass_min' => undef,
      'columnhash' => {
        'metadataid' => {
          'atttypid' => 23,
          'ftype' => 'integer',
          'atthasdef' => 1,
          'qattname' => 'metadataid',
          'attname' => 'metadataid',
          'def' => 'nextval(\'public.ccdb_metadata_metadataid_seq\'::regclass)',
          'realattnum' => 1,
          'attnotnull' => 1,
          'attnum' => 1
        },
        'metadatakey' => {
          'order' => 1,
          'attnum' => 2,
          'attnotnull' => 1,
          'def' => undef,
          'realattnum' => 2,
          'attname' => 'metadatakey',
          'atthasdef' => 0,
          'qattname' => 'metadatakey',
          'ftype' => 'text',
          'atttypid' => 25
        }
      },
      'id' => 4,
      'pkey' => [
        'metadataid'
      ],
      'deltatable' => 'delta_public_ccdb_metadata',
      'safeschema' => 'public',
      'safecols' => [
        'metadatakey'
      ],
      'numpkcols' => 1,
      'hasbinarypk' => 0,
      'pklist' => '"metadataid"',
      'tcolumns' => {
        'SELECT *' => [
          'metadataid',
          'metadatakey'
        ]
      },
      'autokick' => undef,
      'pkeytype' => [
        'integer'
      ],
      'safetable' => 'ccdb_metadata',
      'cols' => [
        'metadatakey'
      ],
      'stagetable' => 'stage_public_ccdb_metadata',
      'code_exception' => [
        $BUCARDO1->{'rellist'}[0]{'code_exception'}[0]
      ],
      'vacuum_after_copy' => 1
    }
  ],
  'sourcedbh' => bless( {}, 'DBIx::Safe' ),
  'message' => '',
  'goatlist' => $BUCARDO1->{'rellist'},
  'warning' => '',
  'endsync' => '',
  'nextcode' => ''
};