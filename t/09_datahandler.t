use strict;
use warnings;
use utf8;
use Test::More;
use Test::MockTime qw/
    set_fixed_time
/;
use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::DataHandler;
use Plack::Request;

# use test db
$ENV{PLACK_ENV} = 'test';
my $c = OIDC::Lite::Demo::Server->new;
$c->setup_schema();
$c->clear_data();

my $ts = time();
set_fixed_time($ts);

subtest "new" => sub {
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new;
    ok( $dh, q{DataHandler->new} );
};

subtest "validate_client_by_id" => sub {
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new;
    my $result = $dh->validate_client_by_id;
    ok( !$result, q{client_id is undef} );
    ok( !$dh->get_client_info, q{client is not set} );

    $result = $dh->validate_client_by_id(q{sample_client_id_invalid});
    ok( !$result, q{client_id is invalid} );
    ok( !$dh->get_client_info, q{client is not set} );

    $result = $dh->validate_client_by_id(q{sample_client_id});
    ok( $result, q{client_id is valid} );
    ok( $dh->get_client_info, q{client is not set} );
};

subtest "validate_client_for_authorization" => sub {
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new;
    my $result = $dh->validate_client_for_authorization;
    ok( !$result, q{params are undef} );

    $result = $dh->validate_client_for_authorization(q{sample_client_id}, q{invalid});
    ok( !$result, q{response_type is invalid} );

    $result = $dh->validate_client_for_authorization(q{sample_client_id}, q{code});
    ok( $result, q{params are invalid} );
};

subtest "validate_redirect_uri" => sub {
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new;
    my $result = $dh->validate_redirect_uri;
    ok( !$result, q{params are undef} );

    $result = $dh->validate_redirect_uri(q{sample_client_id}, q{invalid});
    ok( !$result, q{redirect_uri is invalid} );

    $result = $dh->validate_redirect_uri(q{sample_client_id}, q{http://localhost:5000/sample/callback});
    ok( $result, q{params are valid} );
};

subtest "validate_scope" => sub {
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new;
    my $result = $dh->validate_scope;
    ok( !$result, q{params are undef} );

    $result = $dh->validate_scope(q{sample_client_id}, q{invalid});
    ok( !$result, q{scope is invalid} );

    $result = $dh->validate_scope(q{sample_client_id}, q{openid});
    ok( $result, q{params are valid} );
};

subtest "create_id_token" => sub {
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new;
    my $id_token = $dh->create_id_token;
    ok( !$id_token, q{params are undef} );

    my $request = Plack::Request->new({
                    REQUEST_METHOD => q{GET},
                    QUERY_STRING   => q{client_id=sample_client_id&nonce=random_nonce_str},
                  });

    $dh = OIDC::Lite::Demo::Server::DataHandler->new(request => $request);
    $dh->validate_client_by_id(q{sample_client_id});
    $id_token = $dh->create_id_token();
    isa_ok( $id_token, q{OIDC::Lite::Model::IDToken});
    is( $id_token->header->{typ}, q{JOSE}, q{id_token : header : typ} );
    is( $id_token->header->{alg}, q{RS256}, q{id_token : header : alg} );
    is( $id_token->header->{kid}, 1, q{id_token : header : kid} );
    is( $id_token->payload->{iss}, $c->config->{OIDC}->{id_token}->{iss}, q{id_token : payload : iss} );
    is( $id_token->payload->{aud}, q{sample_client_id}, q{id_token : payload : aud} );
    is( $id_token->payload->{iat}, time(), q{id_token : payload : iat} );
    is( $id_token->payload->{exp}, time() + $c->config->{OIDC}->{id_token}->{expires_in}, q{id_token : payload : exp} );
    is( $id_token->payload->{sub}, 1, q{id_token : payload : sub} );
    is( $id_token->payload->{nonce}, q{random_nonce_str}, q{id_token : payload : nonce} );
};

subtest "create_or_update_auth_info and get_auth_info_by_*" => sub {
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new;
    my $info = $dh->create_or_update_auth_info;
    ok( !$info, q{args are undef} );

    my $args = {
        client_id   => q{sample_client_id},
        user_id     => 1,
        scope       => q{openid},
        id_token    => q{id_token_string},
    };
    $info = $dh->create_or_update_auth_info(%$args);
    ok( !$info, q{redirect_uri is undef} );

    my $request = Plack::Request->new({
                    REQUEST_METHOD => q{GET},
                    QUERY_STRING   => q{redirect_uri=http://localhost:5000/sample/callback},
                  });
    $dh = OIDC::Lite::Demo::Server::DataHandler->new(request => $request);
    $info = $dh->create_or_update_auth_info(%$args);
    ok( $info, q{args and redirect_uri are valid} );
    isa_ok( $info, q{OIDC::Lite::Demo::Server::Web::M::AuthInfo});
    is( $info->id, 1, q{auth_info->id} );
    ok( $info->code, q{auth_info->code} );
    is( $info->code_expired_on, time() + 5*60, q{auth_info->code_expired_on} );

    my $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_id($c->db, $info->id);
    is_deeply( $saved_info, $info, q{found auth_info is valid});

    $saved_info = $dh->get_auth_info_by_id($info->id);
    is_deeply( $saved_info, $info, q{get_auth_info_by_id is valid});

    $saved_info = $dh->get_auth_info_by_code($info->code);
    is_deeply( $saved_info, $info, q{get_auth_info_by_code is valid});

    $info->set_refresh_token();
    $info->save($c->db);
    $saved_info = $dh->get_auth_info_by_refresh_token($info->refresh_token);
    is_deeply( $saved_info, $info, q{get_auth_info_by_refresh_token is valid});
};

subtest "create_or_update_access_token and get_access_token" => sub {
    my $args = {
        client_id   => q{sample_client_id},
        user_id     => 1,
        scope       => q{openid},
        id_token    => q{id_token_string},
    };
    my $request = Plack::Request->new({
                    REQUEST_METHOD => q{GET},
                    QUERY_STRING   => q{redirect_uri=http://localhost:5000/sample/callback},
                  });
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new(request => $request);
    my $token = $dh->create_or_update_access_token();
    ok( !$token, q{auth_info is undef} );

    my $info = $dh->create_or_update_auth_info(%$args);
    $token = $dh->create_or_update_access_token(auth_info => $info);
    ok( $token, q{auth_info is valid} );
    isa_ok( $token, q{OIDC::Lite::Demo::Server::Web::M::AccessToken});
    is( $token->auth_id, $info->id, q{AccessToken->auth_id eq AuthInfo->id} );
    my $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_id($c->db, $info->id);
    ok( $saved_info, q{auth_info is saved});

    $request = Plack::Request->new({
                    REQUEST_METHOD => q{GET},
                    QUERY_STRING   => q{grant_type=authorization_code&redirect_uri=http://localhost:5000/sample/callback},
              });
    $dh = OIDC::Lite::Demo::Server::DataHandler->new(request => $request);
    $info = $dh->create_or_update_auth_info(%$args);
    $token = $dh->create_or_update_access_token(auth_info => $info);
    isa_ok( $token, q{OIDC::Lite::Demo::Server::Web::M::AccessToken});
    is( $token->auth_id, $info->id, q{AccessToken->auth_id eq AuthInfo->id} );

    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_id($c->db, $info->id);
    ok( !$saved_info->code, q{auth_info->code is deleted});
    is( $saved_info->code_expired_on, 0, q{auth_info->code_expired_on is deleted});

    my $decoded_token = $dh->get_access_token($token->token);
    is_deeply($decoded_token, $token, q{get_access_token});
};

$c->clear_data();
done_testing;
