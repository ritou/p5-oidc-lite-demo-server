use strict;
use warnings;
use utf8;
use Test::More;
use Test::MockTime qw/
    set_fixed_time
/;
use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::Web::M::AccessToken;
use OIDC::Lite::Demo::Server::Web::M::AuthInfo;

my $ts = time();
set_fixed_time($ts);

subtest "create" => sub {
    my $token = OIDC::Lite::Demo::Server::Web::M::AccessToken->create();
    ok( !$token, q{no auth_info} );

    my $args = {
        user_id => 1,
        client_id => q{sample_client_id},
        scope => q{openid},
    };
    my $info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->create(%$args);
    $info->id(100);
    $token = OIDC::Lite::Demo::Server::Web::M::AccessToken->create($info);
    is( $token->auth_id, 100, q{AccessToken->auth_id} );
    is( $token->expires_in, 86400, q{AccessToken->expires_in} );
    is( $token->created_on, time(), q{AccessToken->created_on} );
};

subtest "validate" => sub {
    my $args = {
        user_id => 1,
        client_id => q{sample_client_id},
        scope => q{openid},
    };
    my $info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->create(%$args);
    $info->id(100);
    my $token = OIDC::Lite::Demo::Server::Web::M::AccessToken->create($info);
    my $decoded_token = OIDC::Lite::Demo::Server::Web::M::AccessToken->validate($token->token);
    is_deeply($decoded_token, $token, q{decoded AccessToken is valid});

    set_fixed_time($ts - 86400 - 1);
    $token = OIDC::Lite::Demo::Server::Web::M::AccessToken->create($info);
    set_fixed_time($ts);
    $decoded_token = OIDC::Lite::Demo::Server::Web::M::AccessToken->validate($token->token);
    ok( !$decoded_token, q{AccessToken is expired} );
};

done_testing;
