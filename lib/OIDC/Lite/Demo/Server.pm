package OIDC::Lite::Demo::Server;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
use 5.008001;
our $VERSION = '0.01';

__PACKAGE__->load_plugin(qw/DBI/);

# initialize database
use DBI;
sub setup_schema {
    my $self = shift;
    my $dbh = $self->dbh();
    my $driver_name = $dbh->{Driver}->{Name};
    my $fname = lc("sql/${driver_name}.sql");
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    my $source = do { local $/; <$fh> };
    for my $stmt (split /;/, $source) {
        next unless $stmt =~ /\S/;
        $dbh->do($stmt) or die $dbh->errstr();
    }
}

sub clear_data {
    my $self = shift;

    my $dbh = $self->dbh();
    my $driver_name = $dbh->{Driver}->{Name};
    my $fname = lc("sql/${driver_name}_clear.sql");
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    my $source = do { local $/; <$fh> };
    for my $stmt (split /;/, $source) {
        next unless $stmt =~ /\S/;
        $dbh->do($stmt) or die $dbh->errstr();
    }
}

use Teng;
use Teng::Schema::Loader;
use OIDC::Lite::Demo::Server::DB;
my $schema;
sub db {
    my $self = shift;
    if ( !defined $self->{db} ) {
        my $conf = $self->config->{'DBI'}
        or die "missing configuration for 'DBI'";
        my $dbh = DBI->connect(@{$conf});
        if ( !defined $schema ) {
            $self->{db} = Teng::Schema::Loader->load(
                namespace => 'OIDC::Lite::Demo::Server::DB',
                dbh       => $dbh,
	    );
            $schema = $self->{db}->schema;
        } else {
            $self->{db} = OIDC::Lite::Demo::Server::DB->new(
                dbh    => $dbh,
                schema => $schema,
	    );
        }
    }
    return $self->{db};
}

1;
__END__

=head1 NAME

OIDC::Lite::Demo::Server - OpenID Connect Demo Server(OP) using OIDC::Lite

=head1 DESCRIPTION

OpenID Connect Demo Server(OP) using OIDC::Lite

=head1 SYNOPSIS

For setup, please run the following command.

    # 0. obtain src and carton setup
    $ git clone https://github.com/ritou/p5-oidc-lite-demo-server.git
    $ cd p5-oidc-lite-demo-server
    $ carton install
    
    # 1. test
    $ carton exec -- perl Build.PL
    $ carton exec -- ./Build test
    
    # 2. Run your demo server
    $ carton exec -- plackup -r -p 5001

When plack is launched, try to access http://localhost:5001/
If OIDC::Lite::Demo::Client is installed and run server, 
you are able to try authorization flow with sample client.

=head1 AUTHOR

Ryo Ito E<lt>ritou.06@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Ryo Ito

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
