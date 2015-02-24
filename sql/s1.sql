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

CREATE TABLE IF NOT EXISTS tbl_logins (
  login     VARCHAR(128) PRIMARY KEY,
  password  VARCHAR(64),
  create_at TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
  user_id   INTEGER
);

CREATE TABLE IF NOT EXISTS tbl_tokens (
  token         VARCHAR(128) PRIMARY KEY,
  update_at     TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
  live_seconds  INTEGER
);

-- need re-design
--CREATE TABLE IF NOT EXISTS tbl_accounts (
--  account_name  VARCHAR(64) PRIMARY KEY,
--  password      VARCHAR(32),
--  admin_id      INTEGER,
--  email         VARCHAR(64),
--  phone         VARCHAR(16),
--  create_at     TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
--  update_at     TIMESTAMP WITHOUT TIME ZONE DEFAULT (NOW() AT TIME ZONE 'UTC'),
--  salt          VARCHAR(32)
--);


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

CREATE OR REPLACE FUNCTION sp_create_login(login VARCHAR, password VARCHAR) RETURNS INTEGER AS $$
DECLARE
    _now TIMESTAMP := NOW();
    _msg VARCHAR;
    _uid INTEGER;
BEGIN

    SELECT MAX(user_id) FROM tbl_logins t INTO _uid;

    IF _uid < 100 THEN
        _uid = 100;
    END IF; -- SKIP RESERVED IDS.
    _uid := _uid + 1;

    INSERT INTO tbl_logins
    VALUES (login, password, _now, _uid);

    _msg := 'created login : ' || login;
    INSERT INTO tbl_logs(ts, info)
    VALUES (_now, _msg);

    RETURN _uid;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_check_login(login_ VARCHAR, password_ VARCHAR) RETURNS INTEGER AS $$
DECLARE
    _uid INTEGER;
BEGIN

    SELECT user_id FROM tbl_logins t WHERE t.login = login_ INTO _uid;

    IF _uid IS NULL THEN
        RETURN -1;
    END IF;

    IF _uid > 100 THEN
    -- Real user id start from 101
        SELECT user_id FROM tbl_logins t WHERE t.login = login_ AND t.password = password_ INTO _uid;
        IF _uid IS NULL THEN
            RETURN 0;
        END IF;
    END IF;

    RETURN _uid;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION sp_get_logins(user_id_ INTEGER)
    RETURNS TABLE(login VARCHAR, password VARCHAR) AS $$
DECLARE
BEGIN

    FOR login, password IN SELECT * FROM tbl_logins t WHERE t.user_id = user_id_ LOOP
        -- Real user id start from 101
        IF user_id_ > 100 THEN -- NOT SHOW PASSWORD
            password := '***';
        END IF;
        RETURN NEXT ;
    END LOOP;

END;
$$ LANGUAGE plpgsql;