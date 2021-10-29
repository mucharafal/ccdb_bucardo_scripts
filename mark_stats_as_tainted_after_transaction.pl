use strict;
use warnings;
use Data::Dumper;

my $info = shift;
my $dbh_offline = $info->{dbh}->{ccdb_offline};
my $dbh_online = $info->{dbh}->{ccdb_online};

my $markStatsTableAsTainted = "update ccdb_helper_table set value = 1 where key = \'ccdb_stats_tainted\';";
$dbh_offline->do($markStatsTableAsTainted);
$dbh_online->do($markStatsTableAsTainted);

my $file = '/tmp/bucardoDump9.txt';

open my $fh, '>:encoding(UTF-8)', $file or do {
	return;
};

print $fh Dumper $info;
close $fh;

return;
