use strict;
use warnings;
use utf8;
use Test::More;
use Test::MockTime qw/
    set_fixed_time
/;
use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::Web::M::AuthInfo;

# use test db
$ENV{PLACK_ENV} = 'test';
my $c = OIDC::Lite::Demo::Server->new;
$c->setup_schema();
$c->clear_data();

my $ts = time();
set_fixed_time($ts);

subtest "create" => sub {
    my $info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->create();
    ok( !$info, q{no args} );
    my $args = {
        user_id => 1,
        client_id => q{sample_client_id},
        scope => q{openid},
    };
    $info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->create(%$args);
    is( $info->id, 0, q{AuthInfo->id} );    
    is( $info->user_id, $args->{user_id}, q{AuthInfo->user_id} );    
    is( $info->client_id, $args->{client_id}, q{AuthInfo->client_id} );    
    is( $info->scope, $args->{scope}, q{AuthInfo->scope} );    
    is( $info->code, q{}, q{AuthInfo->code} );    
    is( $info->code_expired_on, 0, q{AuthInfo->code_expired_on} );    
    is( $info->refresh_token, q{}, q{AuthInfo->refresh_token} );    
    is( $info->refresh_token_expired_on, 0, q{AuthInfo->refresh_token_expired_on} );    
    is( $info->userinfo_claims->[0], q{sub}, q{AuthInfo->userinfo_claims} );    
};

subtest "code and refresh_token" => sub {
    my $args = {
        user_id => 1,
        client_id => q{sample_client_id},
        scope => q{openid},
    };
    my $info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->create(%$args);
    $info->set_code();
    ok( $info->code, q{AuthInfo->code} );    
    is( $info->code_expired_on, $ts + 5*60, q{AuthInfo->code_expired_on} );    

    $info->unset_code();
    is( $info->code, q{}, q{AuthInfo->code} );    
    is( $info->code_expired_on, 0, q{AuthInfo->code_expired_on} );    

    $info->set_refresh_token();
    ok( $info->refresh_token, q{AuthInfo->refresh_token} );    
    is( $info->refresh_token_expired_on, $ts + 30*24*60*60, q{AuthInfo->refresh_token_expired_on} );    
};

subtest "db" => sub {
    my $args = {
        user_id => 1,
        client_id => q{sample_client_id},
        scope => q{openid},
        redirect_uri => q{http://localhost:5000/sample/callback},
        id_token => q{id_token_str},
    };
    my $info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->create(%$args);
    $info->set_code();
    $info->set_refresh_token();
    $info->save($c->db);
    is( $info->id, 1, q{AuthInfo->id} );   

    my $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_id($c->db, 0);
    ok( !$saved_info, q{id is invalid} );

    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_id($c->db, $info->id);
    ok( $saved_info, q{id is valid} );
    is_deeply( $saved_info, $info );

    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_code($c->db, q{invalid});
    ok( !$saved_info, q{code is invalid} );

    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_code($c->db, $info->code);
    ok( $saved_info, q{code is valid} );
    is_deeply( $saved_info, $info );

    set_fixed_time($ts + 5*60 + 1);
    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_code($c->db, $info->code);
    ok( !$saved_info, q{code is expired} );
    set_fixed_time($ts);

    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_refresh_token($c->db, q{invalid});
    ok( !$saved_info, q{refresh_token is invalid} );

    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_refresh_token($c->db, $info->refresh_token);
    ok( $saved_info, q{refresh_token is valid} );
    is_deeply( $saved_info, $info );

    set_fixed_time($ts + 30*24*60*60 + 1);
    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_refresh_token($c->db, $info->refresh_token);
    ok( !$saved_info, q{refresh_token is expired} );
    set_fixed_time($ts);

    # update
    $info->user_id(2);
    $info->save($c->db);
    is( $info->id, 1, q{AuthInfo->id} );

    $saved_info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->find_by_id($c->db, $info->id);
    ok( $saved_info, q{id is valid} );
    is_deeply( $saved_info, $info );
};

$c->clear_data();
done_testing;
