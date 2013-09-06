CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);

-- AuthInfo
CREATE TABLE IF NOT EXISTS auth_info (
    id              INTEGER PRIMARY KEY,
    client_id       INTEGER NOT NULL,
    user_id         INTEGER NOT NULL,
    scope           TEXT NOT NULL,
    refresh_token   TEXT,
    code            TEXT,
    redirect_uri    TEXT,
    id_token        TEXT,
    userinfo_claims TEXT,
    code_expired_on INTEGER,
    refresh_token_expired_on INTEGER
);

-- client info
CREATE TABLE IF NOT EXISTS clients (
    id                      INTEGER PRIMARY KEY,
    name                    TEXT NOT NULL,
    client_id               TEXT NOT NULL UNIQUE,
    client_secret           TEXT,
    redirect_uris           TEXT,
    client_type             INTEGER,
    is_disabled             INTEGER
);
