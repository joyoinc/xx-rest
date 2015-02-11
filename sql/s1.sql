CREATE TABLE IF NOT EXISTS tbl_logs (
  info	VARCHAR(256),
  ts	TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC')
);

CREATE TABLE IF NOT EXISTS tbl_endpoints (
  verb      VARCHAR(8),
  resource  VARCHAR(64),
  detail    TEXT,
  status    VARCHAR(8), -- READY, TODO, INIT
  update_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC') 
);

CREATE TABLE IF NOT EXISTS tbl_accounts (
  account_name		VARCHAR(64) PRIMARY KEY,
  password		VARCHAR(32),
  admin_name		VARCHAR(32),
  email			VARCHAR(64),
  phone			VARCHAR(16),
  create_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
  update_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
  salt			VARCHAR(32)
);

CREATE OR REPLACE FUNCTION sp_create_account(account VARCHAR, password VARCHAR, admin VARCHAR, email VARCHAR, phone VARCHAR, salt VARCHAR) RETURNS INTEGER AS $$
DECLARE
    _now TIMESTAMP := NOW();
    _msg VARCHAR;
BEGIN
    INSERT INTO tbl_accounts(account_name, password, admin_name, email, phone, create_at, update_at, salt)
    VALUES (account, password, admin, email, phone, _now, _now, salt);

    _msg := 'created account ' || account;
    INSERT INTO tbl_logs(ts, info) 
    VALUES (_now, _msg);

    RETURN 0;
END;
$$ LANGUAGE plpgsql;