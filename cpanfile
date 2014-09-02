requires 'Amon2', '6.09';
requires 'Text::Xslate', '3.3.3';
requires 'Amon2::DBI'                     , '0.32';
requires 'DBD::SQLite'                    , '1.42';
requires 'HTML::FillInForm::Lite'         , '1.13';
requires 'JSON'                           , '2.90';
requires 'Module::Functions'              , '2.1.3';
requires 'Plack::Middleware::ReverseProxy', '0.15';
requires 'Plack::Middleware::Session'     , '0.22';
requires 'Plack::Session'                 , '0.22';
requires 'Test::WWW::Mechanize::PSGI'     , '0.35';
requires 'Time::Piece'                    , '1.20';
requires 'Teng'                           , '0.25';

requires 'OAuth::Lite2'                   , '0.10';
requires 'OIDC::Lite'                     , '0.08';
requires 'Crypt::OpenSSL::Random'         , '0';
requires 'Digest::SHA'                    , '0';
requires 'Module::Find'                   , '0';

requires 'Router::Simple::Sinatraish'     , '0.03';
requires 'Amon2::Plugin::Web::CSRFDefender' , '7.02';

on 'configure' => sub {
   requires 'Module::Build', '0.38';
   requires 'Module::CPANfile', '0.9010';
};

on 'test' => sub {
   requires 'Test::More', '0.98';
   requires 'Test::MockObject', '0';
   requires 'Test::MockTime', '0';
};
