use strict;
use warnings;

my $info = shift;
my $dbh_offline = $info->{dbh}->{ccdb_offline};
my $dbh_online = $info->{dbh}->{ccdb_online};

my $markStatsTableAsTainted = "update ccdb_helper_table set value = 1 where key = 'ccdb_stats_tainted';"; 
$dbh_offline->do($markStatsTableAsTainted);
$dbh_online->do($markStatsTableAsTainted);

return;
