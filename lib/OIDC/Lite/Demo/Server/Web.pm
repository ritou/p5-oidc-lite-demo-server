package OIDC::Lite::Demo::Server::Web;
use strict;
use warnings;
use utf8;
use parent qw/OIDC::Lite::Demo::Server Amon2::Web/;
use File::Spec;

# load all controller classes
use Module::Find ();
Module::Find::useall("OIDC::Lite::Demo::Server::Web::C");

# dispatcher
use OIDC::Lite::Demo::Server::Web::Dispatcher;
sub dispatch {
    return (OIDC::Lite::Demo::Server::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::CSRFDefender' => {
        post_only => 1,
        no_validate_hook => 1,
    },
);

# setup view
use OIDC::Lite::Demo::Server::Web::View;
{
    my $view = OIDC::Lite::Demo::Server::Web::View->make_instance(__PACKAGE__);
    sub create_view { $view }
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ( $c ) = @_;
        # ...
        return;
    },
);

1;
