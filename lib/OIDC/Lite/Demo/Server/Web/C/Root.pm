package OIDC::Lite::Demo::Server::Web::C::Root;
use strict;
use warnings;

sub index {
    my ($class, $c) = @_;   
    return $c->render(
        "index.tt" => {
        }
    );
}

1;
