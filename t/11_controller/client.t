use strict;
use warnings;
use utf8;
use Test::More;
use Test::MockObject;
use Plack::Request;
use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::Web::C::Clients;

subtest "index" => sub {
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'db' => sub{return undef},
        'render' => sub{
            my ($class, $url, $args) = @_;
            $args->{render} = $url;
            return $args;
        },
    );
    my $c = OIDC::Lite::Demo::Server->new();
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'find_all' => sub{
            return [];
        },
    );
    my $res = OIDC::Lite::Demo::Server::Web::C::Clients->index($c);
    is( $res->{render}, q{clients/index.tt}, q{no clients});
    is( $res->{clients_cnt}, 0, q{clients_cnt});
    is_deeply( $res->{clients}, [], q{clients});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'find_all' => sub{
            return [
                {
                    'id' => 1,
                    'name' => q{Sample Client},
                    'client_id' => q{sample_client_id},
                    'client_secret' => q{sample_client_secret},
                    'redirect_uris' => [
                        q{http://localhost:5000/sample/callback},
                    ],
                    'allowed_response_types' => [
                        q{code}, q{id_token}, q{token},
                        q{code id_token}, q{id_token token}, q{code token},
                        q{code id_token token},
                    ],
                    'allowed_grant_types' => [
                        q{authorization_code},
                        q{refresh_token},
                    ],
                    'client_type' => 4,
                    'is_disabled' => 0,
                },
            ];
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->index($c);
    is( $res->{render}, q{clients/index.tt}, q{1 clients});
    is( $res->{clients_cnt}, 1, q{clients_cnt});
    is_deeply( $res->{clients}, OIDC::Lite::Demo::Server::Web::M::Client->find_all(), q{clients});
};

subtest "new" => sub {
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'db' => sub{return undef},
        'render' => sub{
            my ($class, $url, $args) = @_;
            $args->{render} = $url;
            return $args;
        },
    );
    my $c = OIDC::Lite::Demo::Server->new();
    my $res = OIDC::Lite::Demo::Server::Web::C::Clients->new($c);
    is( $res->{render}, q{clients/new.tt}, q{render new.tt});
};

subtest "create" => sub {
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'validate_csrf' => sub{return;},
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
    );
    my $c = OIDC::Lite::Demo::Server->new();
    my $res = OIDC::Lite::Demo::Server::Web::C::Clients->create($c);
    is( $res, q{/clients}, q{validate_csrf is false});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'validate_csrf' => sub{return 1;},
        'req' => sub {
            return Plack::Request->new({
                QUERY_STRING   => q{},
            });
        },
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->create($c);
    is( $res, q{/clients}, q{no param});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'validate_csrf' => sub{return 1;},
        'req' => sub {
            return Plack::Request->new({
                QUERY_STRING   => q{name=test_name&client_type=4&redirect_uris=http://example.com/test},
            });
        },
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
    );
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'create' => sub{
            return;
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->create($c);
    is( $res->{render}, q{clients/new.tt}, q{create failed});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'create' => sub{
            return {
                foo => q{bar},
            };
        },
        'insert' => sub{
            my ($class, $db, $args) = @_;
            is($args->{foo}, q{bar});
            return;
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->create($c);
    is( $res, q{/clients}, q{success});
};

subtest "edit" => sub {
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
        'render' => sub{
            my ($class, $url, $args) = @_;
            $args->{render} = $url;
            return $args;
        },
    );
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'find_by_id' => sub{
            return;
        },
    );
    my $c = OIDC::Lite::Demo::Server->new();
    my $res = OIDC::Lite::Demo::Server::Web::C::Clients->edit($c, undef);
    is( $res, q{/clients}, q{id is undef});

    $res = OIDC::Lite::Demo::Server::Web::C::Clients->edit($c, q{string});
    is( $res, q{/clients}, q{id is string});

    $res = OIDC::Lite::Demo::Server::Web::C::Clients->edit($c, 0);
    is( $res, q{/clients}, q{client is undef});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'find_by_id' => sub{
            return 
            {
                'id' => 1,
                'name' => q{Sample Client},
                'client_id' => q{sample_client_id},
                'client_secret' => q{sample_client_secret},
                'redirect_uris' => [
                    q{http://localhost:5000/sample/callback},
                ],
                'allowed_response_types' => [
                    q{code}, q{id_token}, q{token},
                    q{code id_token}, q{id_token token}, q{code token},
                    q{code id_token token},
                ],
                'allowed_grant_types' => [
                    q{authorization_code},
                    q{refresh_token},
                ],
                'client_type' => 4,
                'is_disabled' => 0,
            },
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->edit($c, 1);
    is( $res->{render}, q{clients/edit.tt}, q{render edit.tt});
    is_deeply( $res->{client}, OIDC::Lite::Demo::Server::Web::M::Client->find_by_id(0), q{client is set});
};

subtest "update" => sub {
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'validate_csrf' => sub{return;},
        'req' => sub {
            return Plack::Request->new({
                QUERY_STRING   => q{aaa},
            });
        },
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
    );
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'find_by_id' => sub{
            return;
        },
    );
    my $c = OIDC::Lite::Demo::Server->new();
    my $res = OIDC::Lite::Demo::Server::Web::C::Clients->update($c, undef);
    is( $res, q{/clients}, q{id is undef});

    $res = OIDC::Lite::Demo::Server::Web::C::Clients->update($c, q{string});
    is( $res, q{/clients}, q{id is undef});

    $res = OIDC::Lite::Demo::Server::Web::C::Clients->update($c, 1);
    is( $res, q{/clients}, q{validate_csrf is false});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'validate_csrf' => sub{return 1;},
        'req' => sub {
            return Plack::Request->new({
                QUERY_STRING   => q{aaa},
            });
        },
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->update($c, 1);
    is( $res, q{/clients}, q{client is undef});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'find_by_id' => sub{
            return 
            {
                'id' => 1,
                'name' => q{Sample Client},
                'client_id' => q{sample_client_id},
                'client_secret' => q{sample_client_secret},
                'redirect_uris' => [
                    q{http://localhost:5000/sample/callback},
                ],
                'allowed_response_types' => [
                    q{code}, q{id_token}, q{token},
                    q{code id_token}, q{id_token token}, q{code token},
                    q{code id_token token},
                ],
                'allowed_grant_types' => [
                    q{authorization_code},
                    q{refresh_token},
                ],
                'client_type' => 4,
                'is_disabled' => 0,
            },
        },
        'update' => sub{
            my ($class, $db, $args) = @_;
            is($args->{name}, q{test_name});
            is($args->{client_type}, 4);
            is_deeply($args->{redirect_uris}, [q{http://example.com/test}]);
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->update($c, 1);
    is( $res, q{/clients}, q{no param});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'validate_csrf' => sub{return 1;},
        'req' => sub {
            return Plack::Request->new({
                QUERY_STRING   => q{name=test_name&client_type=4&redirect_uris=http://example.com/test},
            });
        },
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->update($c, 1);
    is( $res, q{/clients}, q{success});

};

subtest "disable" => sub {
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'validate_csrf' => sub{return;},
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
    );
    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'find_by_id' => sub{
            return;
        },
    );
    my $c = OIDC::Lite::Demo::Server->new();
    my $res = OIDC::Lite::Demo::Server::Web::C::Clients->disable($c, undef);
    is( $res, q{/clients}, q{id is undef});

    $res = OIDC::Lite::Demo::Server::Web::C::Clients->disable($c, q{string});
    is( $res, q{/clients}, q{id is string});

    $res = OIDC::Lite::Demo::Server::Web::C::Clients->disable($c, 1);
    is( $res, q{/clients}, q{validate_csrf is false});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server',
        'new' => sub{bless {}, shift},
        'validate_csrf' => sub{return 1;},
        'db' => sub{return undef},
        'redirect' => sub{
            my ($class, $url) = @_;
            return $url;
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->disable($c, 0);
    is( $res, q{/clients}, q{client is undef});

    Test::MockObject->fake_module(
        'OIDC::Lite::Demo::Server::Web::M::Client',
        'find_by_id' => sub{
            return 
            {
                'id' => 1,
                'name' => q{Sample Client},
                'client_id' => q{sample_client_id},
                'client_secret' => q{sample_client_secret},
                'redirect_uris' => [
                    q{http://localhost:5000/sample/callback},
                ],
                'allowed_response_types' => [
                    q{code}, q{id_token}, q{token},
                    q{code id_token}, q{id_token token}, q{code token},
                    q{code id_token token},
                ],
                'allowed_grant_types' => [
                    q{authorization_code},
                    q{refresh_token},
                ],
                'client_type' => 4,
                'is_disabled' => 0,
            },
        },
        'update' => sub{
            my ($class, $db, $args) = @_;
            is( $args->{is_disabled}, 1, q{update with disabled flag} );
        },
    );
    $res = OIDC::Lite::Demo::Server::Web::C::Clients->disable($c, 1);
    is( $res, q{/clients}, q{success});
};

done_testing;
