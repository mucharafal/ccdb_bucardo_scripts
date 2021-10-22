use strict;
use warnings;
use Data::Dumper;

my $BUCARDO1 = {
  'dbinfo' => {
    'ccdb_2a' => {
      'priority' => 0,
      'does_async' => 1,
      'does_dbi' => 1,
      'does_sql' => 1,
      'does_truncate' => 1,
      'does_makedelta' => new {},
      'backend' => 26672,
      'dbname' => 'ccdb',
      'deltatotal' => 1,
      'needsvac' => 2,
      'dbconn' => '',
      'makedelta' => 0,
      'DBGROUPNAME' => 'dbgroup sync',
      'istarget' => 1,
      'name' => 'ccdb_2a',
      'cdate' => '2020-12-01 22:13:15.226567+01',
      'server_side_prepares' => 1,
      'does_savepoints' => 1,
      'does_append_only' => 0,
      'pgpass' => undef,
      'does_cascade' => 1,
      'role' => 'source',
      'triggers_enabled' => 1,
      'status' => 'active',
      'has_mysql_timestamp_issue' => 0,
      'dbport' => '',
      'dbservice' => '',
      'dbuser' => 'bucardo',
      'dbtype' => 'postgres',
      'issource' => 1,
      'does_ANY_clause' => 1,
      'deltaquick' => {
        'public.ccdb_paths' => '1'
      },
      'dbhost' => '2a.ib',
      'dbdsn' => '',
      'dbpass' => undef,
      'async_active' => 0,
      'does_limit' => 1,
      'deltazero' => 0
    },
    'ccdb_3a' => {
      'priority' => 0,
      'does_async' => 1,
      'does_dbi' => 1,
      'does_sql' => 1,
      'does_truncate' => 1,
      'does_makedelta' => {},
      'backend' => 31329,
      'dbname' => 'ccdb',
      'deltatotal' => 1,
      'needsvac' => 2,
      'dbconn' => '',
      'makedelta' => 0,
      'DBGROUPNAME' => 'dbgroup sync',
      'istarget' => 1,
      'name' => 'ccdb_3a',
      'cdate' => '2020-12-01 22:13:07.655581+01',
      'server_side_prepares' => 1,
      'does_savepoints' => 1,
      'does_append_only' => 0,
      'pgpass' => undef,
      'does_cascade' => 1,
      'role' => 'source',
      'triggers_enabled' => 1,
      'status' => 'active',
      'has_mysql_timestamp_issue' => 0,
      'dbport' => '',
      'dbservice' => '',
      'dbuser' => 'bucardo',
      'dbtype' => 'postgres',
      'issource' => 1,
      'does_ANY_clause' => 1,
      'deltaquick' => {
        'public.ccdb_paths' => '1'
      },
      'dbhost' => '3a.ib',
      'dbdsn' => '',
      'dbpass' => undef,
      'async_active' => 0,
      'does_limit' => 1,
      'deltazero' => 0
    }
  },
  'schemaname' => 'public',
  'syncname' => 'sync_2a_and_3a',
  'rows' => new {},
  'shared' => new {},
  'conflicts' => {
    '5' => {
      'ccdb_2a' => 1,
      'ccdb_3a' => 1
    }
  },
  'error' => '',
  'lastcode' => '',
  'sendmail' => sub { "DUMMY" },
  'tablename' => 'ccdb_paths',
  'version' => '5.6.0',
  'message' => '',
  'skip' => '',
  'warning' => '',
  'dbh' => {
    'ccdb_2a' => bless( new {}, 'DBIx::Safe' ),
    'ccdb_3a' => bless( new {}, 'DBIx::Safe' )
  },
  'endsync' => ''
};

my $info = \%BUCARDO1;
my $file = '/tmp/bucardoDump8.txt';

open my $fh, '>:encoding(UTF-8)', $file or do {
	return;
};

print $fh Dumper %info;
close $fh;

$info{'tablewinner'} = 'ccdb_3a';

return;