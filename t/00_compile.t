use strict;
use warnings;
use utf8;
use Test::More;

use_ok $_ for qw(
    OIDC::Lite::Demo::Server
    OIDC::Lite::Demo::Server::DataHandler
    OIDC::Lite::Demo::Server::ProtectedResource
    OIDC::Lite::Demo::Server::Web
    OIDC::Lite::Demo::Server::Web::ViewFunctions
    OIDC::Lite::Demo::Server::Web::Dispatcher
    OIDC::Lite::Demo::Server::Web::C::Authorize
    OIDC::Lite::Demo::Server::Web::M::AccessToken
    OIDC::Lite::Demo::Server::Web::M::AuthInfo
    OIDC::Lite::Demo::Server::Web::M::Client
    OIDC::Lite::Demo::Server::Web::M::ResourceOwner
);

done_testing;
