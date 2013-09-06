package OIDC::Lite::Demo::Server::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;
use OIDC::Lite::Demo::Server::Web::C::Root;
use OIDC::Lite::Demo::Server::Web::C::Authorize;
use OIDC::Lite::Demo::Server::Web::C::Clients;

get '/' => sub {
    my ($c) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Root->index($c);
};

get '/authorize' => sub {
    my ($c) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Authorize->confirm($c);
};

post '/authorize' => sub {
    my ($c) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Authorize->accept($c);
};

# clients
get '/clients' => sub {
    my ($c) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Clients->index($c);
};

get '/clients/new' => sub {
    my ($c) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Clients->new($c);
};

post '/clients/new' => sub {
    my ($c) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Clients->create($c);
};

get '/clients/:id/edit' => sub {
    my ($c, $args) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Clients->edit($c, $args->{id});
};

post '/clients/:id/edit' => sub {
    my ($c, $args) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Clients->update($c, $args->{id});
};

post '/clients/:id/disable' => sub {
    my ($c, $args) = @_;
    return OIDC::Lite::Demo::Server::Web::C::Clients->disable($c, $args->{id});
};

1;
