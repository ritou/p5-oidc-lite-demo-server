use strict;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;

use OIDC::Lite::Server::Endpoint::Token;
use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::Web;
use OIDC::Lite::Demo::Server::ProtectedResource;
use Plack::Session::Store::DBI;
use Plack::Session::State::Cookie;
use DBI;

{
    my $c = OIDC::Lite::Demo::Server->new();
    $c->setup_schema();
}
my $db_config = OIDC::Lite::Demo::Server->config->{DBI} || die "Missing configuration for DBI";

# token endpoint
my $token_endpoint = OIDC::Lite::Server::Endpoint::Token->new(
    data_handler => 'OIDC::Lite::Demo::Server::DataHandler',
);
$token_endpoint->support_grant_types(qw(authorization_code refresh_token));

# userinfo endpoint
my $userinfo_endpoint = OIDC::Lite::Demo::Server::ProtectedResource->new;

builder {

    # URL : / Web App
    mount "/" => builder {
        enable 'Plack::Middleware::Static',
            path => qr{^(?:/static/)},
            root => File::Spec->catdir(dirname(__FILE__));
        enable 'Plack::Middleware::Static',
            path => qr{^(?:/robots\.txt|/favicon\.ico)$},
            root => File::Spec->catdir(dirname(__FILE__), 'static');
        enable 'Plack::Middleware::ReverseProxy';
        enable 'Plack::Middleware::Session',
            store => Plack::Session::Store::DBI->new(
                get_dbh => sub {
                    DBI->connect( @$db_config )
                        or die $DBI::errstr;
                }
            ),
            state => Plack::Session::State::Cookie->new(
                httponly => 1,
            );
        OIDC::Lite::Demo::Server::Web->to_app();
    };

    # Token Endpoint
    mount "/token" => $token_endpoint;

    # Userinfo Endpoint
    mount "/userinfo" => $userinfo_endpoint;
};
