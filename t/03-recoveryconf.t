use PGObject::Util::Replication::Standby;
use Test::More;

plan tests => 10;

my $standby = PGObject::Util::Replication::Standby->new();
ok($standby, 'Got an SMO for the standby');
ok($standby->recoveryconf, 'Got a config handle for the recovery.conf');
is($standby->connection_string, 'postgresql:///postgres', 
    'empty postgresql connection string by default');
$standby->upstream_host('localhost');
is($standby->connection_string, 'postgresql://localhost/postgres', 
'correct connection string with only host set');
$standby->credentials('foo', 'bar');
is($standby->connection_string, "postgresql://foo:bar@localhost/postgres",
  'Correct string wtih username, password, host, and dbname');
my $cstring = $standby->connection_string;
like($standby->recoveryconf_contents, qr/$cstring/, 'generated file contains connection string');
like($standby->recoveryconf_contents, qr/standby_mode/, 'standby_mode set');

$standby = PGObject::Util::Replication::Standby->new();
$standby->from_recoveryconf('t/helpers/recovery.conf');
is($standby->connection_string, 'postgresql:///postgres', 
    'empty postgresql connection string by default');
like($standby->recoveryconf_contents, qr/standby_mode/, 'standby_mode set');

my $standby2 = PGObject::Util::Replication::Standby->new();
mkdir 't/temp';
open $fh, '>', 't/temp/test.tmp';
print $fh $standby->recoveryconf_contents;
$standby2->from_recoveryconf('t/temp/test.tmp');
is($standby2->connection_string, $standby->connection_string, 'connection strings match');
