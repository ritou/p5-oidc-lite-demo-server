# NAME

OIDC::Lite::Demo::Server - OpenID Connect Demo Server(OP) using OIDC::Lite

# DESCRIPTION

OpenID Connect Demo Server(OP) using OIDC::Lite

# SYNOPSIS

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

# AUTHOR

Ryo Ito <ritou.06@gmail.com>

# COPYRIGHT AND LICENSE

Copyright (C) 2013 by Ryo Ito

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.
