use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $dbpath = File::Spec->catfile($basedir, 'db', 'development.db');
+{
    'DBI' => [
        "dbi:SQLite:dbname=$dbpath", '', '',
        +{
            sqlite_unicode => 1,
        }
    ],
    'OIDC' => {
        'id_token' => {
            'iss' => q{localhost:5001},
            'expires_in' => 3600,
            'pub_key' => "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5XxKc3Rz/8EakvZG+Ez9
nCpdn2HGVq0CRD1GZ/fEuM7nHfmy1LzC0VyNa8YkU7Qrb4s/BgSxjFrLvbpFHcUo
o+D3W5TvCR+8RLJLISmUoo4jMb2wDq35DEaJa3j1lGb7o93msFwlSRLwbmcYw08F
H3NEB1IQxkfAv6Z/ddzjDzV1nhbQO/RnO4v4JJ8wR4xxLmo00AJJ7fr8oL51aF9S
kjHU8cjvKFjGW4kcNxxm3+pMCzNtbJvUFQFeTQNBkWt9k83yKA5bhNwK1W4otRPs
l2bP0AyuJtA3tFdWSD1fvIA+l8rywrVom/RbDRUZkm1k+YgbyqyUgJbM5oJkGhwP
fwIDAQAB
-----END PUBLIC KEY-----",
            'priv_key' => "-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEA5XxKc3Rz/8EakvZG+Ez9nCpdn2HGVq0CRD1GZ/fEuM7nHfmy
1LzC0VyNa8YkU7Qrb4s/BgSxjFrLvbpFHcUoo+D3W5TvCR+8RLJLISmUoo4jMb2w
Dq35DEaJa3j1lGb7o93msFwlSRLwbmcYw08FH3NEB1IQxkfAv6Z/ddzjDzV1nhbQ
O/RnO4v4JJ8wR4xxLmo00AJJ7fr8oL51aF9SkjHU8cjvKFjGW4kcNxxm3+pMCzNt
bJvUFQFeTQNBkWt9k83yKA5bhNwK1W4otRPsl2bP0AyuJtA3tFdWSD1fvIA+l8ry
wrVom/RbDRUZkm1k+YgbyqyUgJbM5oJkGhwPfwIDAQABAoIBADYW6Jlz7k9u3Wuc
PrgRtYkUd0K00gHl/23EH48r2CNTKShojV0VLLoaHX80kaVlBwPghzdM7ehOEk2i
1N2ideTChqsAXKMC5uYuPAUR/uWdqO/1bMTY/qWFDqjVNtUGvPMvv0r8PRGPNDph
dHW8b1GtYnBzSF7j1KuXe9109dPEbLQHpOuZijPOGSupJ+pXRc4nRTSasJXLhtVC
2FAhyK/U8vXQbtSLfcsldK0oWCwmTi/OVLYioz4JulyDz6P98M2AZ+WG7OptNcFi
nt5WbX/1JUKpHsPMQhMv/UVVk9hihx0j7qhQw0iDEdx4Por4+sYLeqKLEFIYrf1f
KvAUwgkCgYEA9I7r2x7fxIH9tQczPBa053Nyp5kFgS5BFgXPWUHDPl0+WACDVpih
/w7YCZmdOYc3a2UncOaK1/G9Nh0BogCfl3kMTgDeuS810dB9vM2K684Ay/hnQhTL
vsLnVflFKbIeZWywLxq7/Rzi/gmrK+YoeLJpv2xdAxJQ4gHIfPJC2s0CgYEA8DjX
tpBWN6zn2ui/eKHhwtEKbA4BMHySQ8wtWQ5lLR9DbA8Hs9LxyeQUfvEBu2728/h8
56acCn7D4H1VCBfwIWDKIu+jEqi+RE/kRPnCpV1iBHE0EuB/YN89UGIDpLKfgebK
bDbGbpuEeMfIedvO1FRn4g+P1vNzvWq28qcuq3sCgYEA7eLcT9//YIHlzSK81rVr
sTweiiKSNS9OBmMOZ89NYSuISkfted2srpK82NHBG0WJRgE2VV8cLaQrHikm/nPG
yavoqTO1csMWggphVLdHa8qOAdqWbrQV4HBsYLfBbCaj5JrN4nQJ6tMfhmbXRzNx
qL47mQWKkENPxBhh8hAhsf0CgYEAwrVQIynauEXtqAH/MEgGNWI6kFrJnANcipd0
KjsAxxIQFAYauCbC1GGKO1odjU7j29wNYbYpxFf7bHop8eV1PZi2Ppr+EqGzlqsq
2r2Wh3Kpf/BBxQsyM9K+X+kSCuy9XQ00BYJgVEa5mSxV0m/XtUK08QasEA5EQcO9
hfD8YwECgYEAyHiQ1yuMzVzNKDCUVo2UpiFiVIqOg0Yjoa/tt9MbBwAukYMhRkvU
2CI8jKu8KugD7NArWMpoPcIECk64roYZR0RH4MKWK46OHg2vwPGiOUaWjlsoUcNc
eH+MQwdClxQ8rTr2CxXZKffji8I2Vs9FUE+pep0s3gR072kix3EFdZc=
-----END RSA PRIVATE KEY-----",
        },
    },
};
