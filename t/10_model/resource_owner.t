use strict;
use warnings;
use utf8;
use Test::More;
#use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::Web::M::ResourceOwner;

# use test db
#$ENV{PLACK_ENV} = 'test';
#my $c = OIDC::Lite::Demo::Server->new;
#$c->setup_schema();
#$c->clear_data();

subtest "demo user:find_by_id" => sub {
    my $resource_owner = OIDC::Lite::Demo::Server::Web::M::ResourceOwner->find_by_id();
    ok( !$resource_owner, q{no id} );

    $resource_owner = OIDC::Lite::Demo::Server::Web::M::ResourceOwner->find_by_id(-1);
    ok( !$resource_owner, q{id is invalid} );

    $resource_owner = OIDC::Lite::Demo::Server::Web::M::ResourceOwner->find_by_id(1);
    ok( $resource_owner, q{id is valid} );
    my $demo_user = $OIDC::Lite::Demo::Server::Web::M::ResourceOwner::RESOURCE_OWNERS->{1};
    is_deeply ($resource_owner, $demo_user, q{find from sample user});
    
};

#$c->clear_data();
done_testing;
