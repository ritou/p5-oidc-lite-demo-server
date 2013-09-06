package OIDC::Lite::Demo::Server::ProtectedResource;
use strict;
use warnings;
use utf8;
use overload
    q(&{})   => sub { shift->psgi_app },
    fallback => 1;
use Plack::Request;
use Try::Tiny;
use Params::Validate;
use JSON;

use Plack::Middleware::Auth::OIDC::ProtectedResource;
use OIDC::Lite::Demo::Server;
use OIDC::Lite::Demo::Server::DataHandler;
use OIDC::Lite::Demo::Server::Web::M::ResourceOwner;

sub new {
    my $class = shift;
    bless { }, $class;
}

sub psgi_app {
    my $self = shift;
    return $self->{psgi_app}
        ||= $self->compile_psgi_app;
}

sub compile_psgi_app {
    my $self = shift;
    my $app = sub {
        my $env = shift;
        my $req = Plack::Request->new($env);
        my $res; try {
            $res = $self->handle_request($req);
        } catch {
            $res = $req->new_response(500);
        };
        return $res->finalize;
    };
    return Plack::Middleware::Auth::OIDC::ProtectedResource->wrap($app,
        data_handler => 'OIDC::Lite::Demo::Server::DataHandler',
    );
}

sub handle_request {
    my ($self, $req) = @_;
    my $c = OIDC::Lite::Demo::Server->new();

    my $res;
    my $resource_owner_id = $req->env->{REMOTE_USER};
    my $requested_claims = $req->env->{X_OIDC_USERINFO_CLAIMS};
    
    $res = $req->new_response(200);
    $res->content_type("application/json");
    $res->body(JSON->new->encode($self->userinfo($resource_owner_id, $requested_claims)));
    return $res;
}

sub userinfo {
    my ($class, $resource_owner_id, $requested_claims) = @_;

    my $resource_owner_info = 
        OIDC::Lite::Demo::Server::Web::M::ResourceOwner->find_by_id($resource_owner_id);
    my $claims;
    foreach my $claim (@{$requested_claims}) {
        if ($claim eq q{address}) {
            $claims->{$claim} = encode_json($resource_owner_info->{$claim});
        } else {
            $claims->{$claim} = $resource_owner_info->{$claim};
        }
    }
    return $claims;
}

1;
