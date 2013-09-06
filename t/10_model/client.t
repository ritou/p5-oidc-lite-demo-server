use strict;
use warnings;
use utf8;
use Test::More;
use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::Web::M::Client;

# use test db
$ENV{PLACK_ENV} = 'test';
my $c = OIDC::Lite::Demo::Server->new;
$c->setup_schema();
$c->clear_data();

subtest "sample client:find_by_client_id" => sub {
    my $client = OIDC::Lite::Demo::Server::Web::M::Client->find_by_client_id();
    ok( !$client, q{no client_id} );

    $client = OIDC::Lite::Demo::Server::Web::M::Client->find_by_client_id($c->db, q{invalid_client});
    ok( !$client, q{client_id is invalid} );

    $client = OIDC::Lite::Demo::Server::Web::M::Client->find_by_client_id($c->db, q{sample_client_id});
    ok( $client, q{client_id is valid} );
    my $sample_client = $OIDC::Lite::Demo::Server::Web::M::Client::SAMPLE_CLIENTS->{sample_client_id};
    is_deeply($client, $sample_client, q{find from sample clients});
};

subtest "insert_and_find_and_update" => sub {
    my $client_data = {
        name => q{client_name_1},
        client_id => q{client_id_1},
        client_secret => q{client_secret_1},
        redirect_uris => [
            q{http://localhost:9999/callback1_1},
            q{http://localhost:9999/callback1_2},
        ],
        client_type => 3,
    };

    my $client = OIDC::Lite::Demo::Server::Web::M::Client->insert($c->db, $client_data);
    ok( $client, q{client is insert} );
    is( $client->{name}, $client_data->{name}, q{name is set});
    is( $client->{client_id}, $client_data->{client_id}, q{client_id is set});
    is( $client->{client_secret}, $client_data->{client_secret}, q{client_secret is set});
    is_deeply( $client->{redirect_uris}, $client_data->{redirect_uris}, q{redirect_uris are set});
    ok( $client->{allowed_response_types}, q{allowed_response_types are set});
    ok( $client->{allowed_grant_types}, q{allowed_grant_types are set});
    my $client_2 = OIDC::Lite::Demo::Server::Web::M::Client->find_by_id($c->db, $client->{id});
    is_deeply( $client_2, $client, q{hash refs are matched});
    my $client_3 = OIDC::Lite::Demo::Server::Web::M::Client->find_by_client_id($c->db, $client->{client_id});
    is_deeply($client_3, $client_2);

    $client->{client_type} = 2;
    OIDC::Lite::Demo::Server::Web::M::Client->update($c->db, $client);
    my $client_4 = OIDC::Lite::Demo::Server::Web::M::Client->find_by_id($c->db, $client->{id});
    is_deeply( $client_4->{allowed_response_types}, [q{id_token}, q{id_token token}], q{allowed_response_types are updated});
    is_deeply( $client_4->{allowed_grant_types}, [], q{allowed_grant_types are updated});
    my $clients = OIDC::Lite::Demo::Server::Web::M::Client->find_all($c->db);
    is_deeply( $clients->[0], $client_4);
};

subtest "create_and_find_all" => sub {
    my $client_data = {
        name => q{client_name_web},
        redirect_uris => [
            q{http://localhost:9999/callback1_1},
            q{http://localhost:9999/callback1_2},
        ],
        client_type => 1,
    };
    # [1]
    my $client = OIDC::Lite::Demo::Server::Web::M::Client->create($client_data);
    OIDC::Lite::Demo::Server::Web::M::Client->insert($c->db, $client);

    # [2]
    $client_data->{name} = q{client_name_js};
    $client_data->{client_type} = 2;
    $client = OIDC::Lite::Demo::Server::Web::M::Client->create($client_data);
    OIDC::Lite::Demo::Server::Web::M::Client->insert($c->db, $client);

    # [3]
    $client_data->{name} = q{client_name_mobile_app};
    $client_data->{client_type} = 3;
    $client = OIDC::Lite::Demo::Server::Web::M::Client->create($client_data);
    OIDC::Lite::Demo::Server::Web::M::Client->insert($c->db, $client);

    # [4]
    $client_data->{name} = q{client_name_full};
    $client_data->{client_type} = 4;
    $client = OIDC::Lite::Demo::Server::Web::M::Client->create($client_data);
    OIDC::Lite::Demo::Server::Web::M::Client->insert($c->db, $client);

    my $clients = OIDC::Lite::Demo::Server::Web::M::Client->find_all($c->db);
    ok($clients);
    ok($clients->[4]);
};

$c->clear_data();
done_testing;
