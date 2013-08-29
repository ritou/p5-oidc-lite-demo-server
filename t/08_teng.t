use strict;
use warnings;
use DBI;
use Test::More;
use OIDC::Lite::Demo::Server;

my $dbi = DBI->connect('dbi:SQLite:dbname=db/development.db');
$dbi->do("create table if not exists sessions (id char(72) primary key, session_data text)") or die $dbi->errstr;
my $teng = OIDC::Lite::Demo::Server->new;
is(ref $teng, 'OIDC::Lite::Demo::Server', 'instance');
isa_ok($teng->db, 'Teng', 'instance');
isa_ok($teng->db, 'OIDC::Lite::Demo::Server::DB', 'instance');
$teng->db->insert('sessions', { id => 'abcdefghijklmnopqrstuvwxyz', session_data => 'ka2u' });
my $res = $teng->db->single('sessions', { id => 'abcdefghijklmnopqrstuvwxyz' });
is($res->get_column('session_data'), 'ka2u', 'search');
$teng->db->delete('sessions', {id => 'abcdefghijklmnopqrstuvwxyz'});

done_testing;
