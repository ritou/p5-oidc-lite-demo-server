package OIDC::Lite::Demo::Server::Web::C::Authorize;
use strict;
use warnings;

use JSON qw/encode_json/;
use OAuth::Lite2::Util qw/build_content/;
use OIDC::Lite::Demo::Server::DataHandler;
use OIDC::Lite::Demo::Server::Web::M::ResourceOwner;
use OIDC::Lite::Server::AuthorizationHandler;
use OIDC::Lite::Server::Scope;
use OIDC::Lite::Model::IDToken;

my $RESPONSE_TYPES = [
    q{code}, q{id_token}, q{token},
    q{code id_token}, q{code token}, q{id_token token},
    q{code id_token token}
];

sub confirm {
    my ($class, $c) = @_;

    my $request_uri = $c->req->request_uri;
    my $params = $c->req->query_parameters->as_hashref;
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new(
        request => $c->req,
    );
    my $ah = OIDC::Lite::Server::AuthorizationHandler->new(
        data_handler => $dh,
        response_types => $RESPONSE_TYPES,
    );

    eval {
        $ah->handle_request();
    };
    my $error;
    my $client_info = $dh->get_client_info();
    if ($error = $@) {
        return $c->render(
            "authorize/confirm.tt" => {
                status => $error,
                request_uri => $request_uri,
                params => $params,
                client_info => $client_info,
            }
        );
    }

    # create array ref of returned user claims for display
    my $resource_owner_id = $dh->get_user_id_for_authorization;
    my @scopes = split(/\s/, $c->req->param('scope'));
    my $claims = $class->_get_resource_owner_claims($resource_owner_id, @scopes);

    # confirm screen
    return $c->render(
        "authorize/confirm.tt" => {
            status => q{valid},
            scopes => \@scopes,
            request_uri => $request_uri,
            params => $params,
            client_info => $client_info,
            claims => $claims,
        }
    );
}

sub accept {
    my ($class, $c) = @_;

    my $request_uri = $c->req->request_uri;
    my $params = $c->req->query_parameters->as_hashref;
    my $dh = OIDC::Lite::Demo::Server::DataHandler->new(
        request => $c->req,
    );
    my $ah = OIDC::Lite::Server::AuthorizationHandler->new(
        data_handler => $dh,
        response_types => $RESPONSE_TYPES,
    );

    my $res;
    eval {
        $ah->handle_request();
        if( $c->validate_csrf() && 
            $c->req->param('user_action') ){
            if( $c->req->param('user_action') eq q{accept} ){
                $res = $ah->allow();        
            }else{
                $res = $ah->deny();
            }
        }else{
            $class->confirm($c);
        }
    };
    my $error;
    my $client_info = $dh->get_client_info();
    if ($error = $@) {
        return $c->render(
            "authorize/accept.tt" => {
                status => $error,
                request_uri => $request_uri,
                params => $params,
                client_info => $client_info,
            }
        );
    }

    # create array ref of returned user claims for display
    my $resource_owner_id = $dh->get_user_id_for_authorization;
    my @scopes = split(/\s/, $c->req->param('scope'));
    my $claims = $class->_get_resource_owner_claims($resource_owner_id, @scopes);

    $res->{query_string} = build_content($res->{query});
    $res->{fragment_string} = build_content($res->{fragment});
    $res->{uri} = $res->{redirect_uri};
    if ($res->{query_string}) {
        $res->{uri} .= ($res->{uri} =~ /\?/) ? q{&} : q{?};
        $res->{uri} .= $res->{query_string};
    }
    if ($res->{fragment_string}) {
        $res->{uri} .= q{#}.$res->{fragment_string};
    }

    # confirm screen
    return $c->render(
        "authorize/accept.tt" => {
            status => q{valid},
            scopes => \@scopes,
            request_uri => $request_uri,
            params => $params,
            client_info => $client_info,
            claims => $claims,
            response_info => $res,
        }
    );
}

sub _get_resource_owner_claims {
    my ($class, $resource_owner_id, @scopes) = @_;

    my $resource_owner_info = 
        OIDC::Lite::Demo::Server::Web::M::ResourceOwner->find_by_id($resource_owner_id);
    my $requested_claims = OIDC::Lite::Server::Scope->to_normal_claims(\@scopes);
    my @claims;
    foreach my $claim (@{$requested_claims}) {
        if ($claim eq q{address}) {
            push (@claims, "$claim : ". encode_json($resource_owner_info->{$claim}));
        } else {
            push (@claims, "$claim : $resource_owner_info->{$claim}");
        }
    }
    return \@claims;
}

1;
