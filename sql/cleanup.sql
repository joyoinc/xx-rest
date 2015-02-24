DROP TABLE IF EXISTS tbl_endpoints;
DROP TABLE IF EXISTS tbl_logins;
DROP TABLE IF EXISTS tbl_accounts;
DROP TABLE IF EXISTS tbl_logs;

DROP FUNCTION IF EXISTS sp_check_login(login_ VARCHAR, password_ VARCHAR);
DROP FUNCTION IF EXISTS sp_get_logins(user_id_ INTEGER);
DROP FUNCTION IF EXISTS sp_create_login(login_ VARCHAR, password_ VARCHAR);

DROP FUNCTION IF EXISTS sp_create_account(account VARCHAR, password VARCHAR, admin VARCHAR, email VARCHAR, phone VARCHAR, salt VARCHAR);
