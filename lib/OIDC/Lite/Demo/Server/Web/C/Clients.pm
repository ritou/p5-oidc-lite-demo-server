package OIDC::Lite::Demo::Server::Web::C::Clients;
use strict;
use warnings;
use OIDC::Lite::Demo::Server::Web::M::Client;

sub index {
    my ($class, $c) = @_;

    my $clients = OIDC::Lite::Demo::Server::Web::M::Client->find_all($c->db);
    my $client_cnt = scalar @$clients;

    return $c->render(
        "clients/index.tt" => {
            clients_cnt => $client_cnt,
            clients => $clients,       
        }
    );
}

sub new {
    my ($class, $c) = @_;
    return $c->render(
        "clients/new.tt" => {
        }
    );
}

sub create {
    my ($class, $c) = @_;
    return $c->redirect("/clients") unless $c->validate_csrf();

    return $c->redirect("/clients") unless $c->req->param('name');
    return $c->redirect("/clients") unless ($c->req->param('client_type') &&
                                            $c->req->param('client_type') >= 1 &&
                                            $c->req->param('client_type') <= 4);
    my @uris;
    foreach my $uri (split(/\n/, $c->req->param('redirect_uris'))){
        $uri =~ s/\r\n//g;
        $uri =~ s/\n//g;
        $uri =~ s/\r//g;
        $uri =~ s/\s//g;
        push (@uris, $uri) if $uri;
    }
    return $c->redirect("/clients") unless @uris;
     
    my $data = {
        name => $c->req->param('name'),
        redirect_uris => \@uris,
        client_type => $c->req->param('client_type'),
    };
    my $client = OIDC::Lite::Demo::Server::Web::M::Client->create($data);
    return $c->render(
        "clients/new.tt" => {
        }
    ) unless $client;

    OIDC::Lite::Demo::Server::Web::M::Client->insert($c->db, $client);
    return $c->redirect("/clients");
}

sub edit {
    my ($class, $c, $id) = @_;
    return $c->redirect("/clients") unless ($id && $id =~ /\A[0-9]+\z/);

    my $client = OIDC::Lite::Demo::Server::Web::M::Client->find_by_id($c->db, $id);
    return $c->redirect("/clients") unless $client;

    return $c->render(
        "clients/edit.tt" => {
            client => $client,
        }
    );
}

sub update {
    my ($class, $c, $id) = @_;
    return $c->redirect("/clients") unless ( $c->validate_csrf() && $id && $id =~ /\A[0-9]+\z/);

    my $client = OIDC::Lite::Demo::Server::Web::M::Client->find_by_id($c->db, $id);
    return $c->redirect("/clients") unless $client;

    return $c->redirect("/clients") unless $c->req->param('name');
    return $c->redirect("/clients") unless ($c->req->param('client_type') &&
                                            $c->req->param('client_type') >= 1 &&
                                            $c->req->param('client_type') <= 4);
    my @uris;
    foreach my $uri (split(/\n/, $c->req->param('redirect_uris'))){
        $uri =~ s/\r\n//g;
        $uri =~ s/\n//g;
        $uri =~ s/\r//g;
        $uri =~ s/\s//g;
        push (@uris, $uri) if $uri;
    }
    return $c->redirect("/clients") unless @uris;

    $client->{name} = $c->req->param('name');
    $client->{redirect_uris} = \@uris;
    $client->{client_type} = $c->req->param('client_type');
    OIDC::Lite::Demo::Server::Web::M::Client->update($c->db, $client);

    return $c->redirect("/clients");
}

sub disable {
    my ($class, $c, $id) = @_;
    return $c->redirect("/clients") unless ( $c->validate_csrf() && $id && $id =~ /\A[0-9]+\z/);

    my $client = OIDC::Lite::Demo::Server::Web::M::Client->find_by_id($c->db, $id);
    return $c->redirect("/clients") unless $client;

    $client->{is_disabled} = 1;
    OIDC::Lite::Demo::Server::Web::M::Client->update($c->db, $client);

    return $c->redirect("/clients");
}

1;
