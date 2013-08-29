use strict;
use warnings;
use utf8;
use Test::More;

use_ok $_ for qw(
    OIDC::Lite::Demo::Server
    OIDC::Lite::Demo::Server::Web
    OIDC::Lite::Demo::Server::Web::ViewFunctions
    OIDC::Lite::Demo::Server::Web::Dispatcher
);

done_testing;
