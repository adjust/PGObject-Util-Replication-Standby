use PGObject::Util::Replication::Standby;
use Test::More;

plan tests => 5;

my $standby = PGObject::Util::Replication::Standby0>new();
ok($standby, 'Got an SMO for the standby');
ok($standby->recoveryconf, 'Got a config handle for the recovery.conf');
is($standby->connection_string, 'postgresql://', 
    'empty postgresql connection string by default');
$standby->upstream_host('localhost');
is($standby->connection_string, 'postgresql://localhost/postgres', 
'correct connection string with only host set');
$standby->credentials('foo', 'bar');
is($standby->connection_string, "postgresql://foo:bar@localhost/poostgres",
  'Correct string wtih username, password, host, and dbname');
