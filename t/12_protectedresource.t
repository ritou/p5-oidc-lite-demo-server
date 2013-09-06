use strict;
use warnings;
use Test::More;

use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::Web::M::AuthInfo;
use OIDC::Lite::Demo::Server::Web::M::AccessToken;
use OIDC::Lite::Demo::Server::ProtectedResource;

use Try::Tiny;
use HTTP::Response;
use HTTP::Request;
use HTTP::Message::PSGI;

$ENV{PLACK_ENV} = 'test';
my $c = OIDC::Lite::Demo::Server->new;
$c->setup_schema();
$c->clear_data();

my $app = OIDC::Lite::Demo::Server::ProtectedResource->new;
sub request {
    my $req = shift;
    my $res = try {
        HTTP::Response->from_psgi($app->($req->to_psgi));
    } catch {
        HTTP::Response->from_psgi([500, ["Content-Type" => "text/plain"], [ $_ ]]);
    };
    return $res;
}

my $args = {
    user_id => 1,
    client_id => q{sample_client_id},
    scope => q{openid},
    redirect_uri => q{http://localhost:5000/sample/callback},
    id_token => q{id_token_str},
};
my $info = OIDC::Lite::Demo::Server::Web::M::AuthInfo->create(%$args);
$info->save($c->db);
my $token = OIDC::Lite::Demo::Server::Web::M::AccessToken->create($info);

# invalid_token
my ($req, $res);
$req = HTTP::Request->new("GET" => q{http://localhost:5001/userinfo});
$req->header("Authorization" => sprintf(q{Bearer %s}, q{invalid_token}));
$res = &request($req);
ok(!$res->is_success, 'request should fail');
is($res->header("WWW-Authenticate"), q{Bearer error="invalid_token"}, 'invalid token');

# scope=openid
$req = HTTP::Request->new("GET" => q{http://localhost:5001/userinfo});
$req->header("Authorization" => sprintf(q{Bearer %s}, $token->token));
$res = &request($req);
ok($res->is_success, 'request should not fail');
is($res->content, q{{"sub":1}}, 'successful response');

# full scope
$info->scope(q{openid profile email phone address});
$info->save($c->db);
$req = HTTP::Request->new("GET" => q{http://localhost:5001/userinfo});
$req->header("Authorization" => sprintf(q{Bearer %s}, $token->token));
$res = &request($req);
ok($res->is_success, 'request should not fail');
like($res->content, qr/\"sub\"/, '"sub"');
like($res->content, qr/\"profile\"/, '"profile"');
like($res->content, qr/\"email\"/, '"email"');
like($res->content, qr/\"phone_number\"/, '"phone"');
like($res->content, qr/\"address\"/, '"address"');

done_testing;
