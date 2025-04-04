-- Create Application User and Grant Privileges
-- Run this as SYSDBA

-- Create App User
CREATE USER app_user IDENTIFIED BY password
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS;

-- Grant Basic Privileges
GRANT CREATE SESSION TO app_user;
GRANT CREATE TABLE TO app_user;
GRANT CREATE VIEW TO app_user;
GRANT CREATE PROCEDURE TO app_user;
GRANT CREATE SEQUENCE TO app_user;
GRANT CREATE TRIGGER TO app_user;

-- Grant Object Privileges
GRANT SELECT ON v_$session TO app_user;
GRANT SELECT ON v_$sql TO app_user;
GRANT SELECT ON dba_data_files TO app_user;
GRANT SELECT ON dba_free_space TO app_user;
GRANT SELECT ON v_$lock TO app_user;

-- Grant System Privileges
GRANT SELECT ANY TABLE TO app_user;
GRANT INSERT ANY TABLE TO app_user;
GRANT UPDATE ANY TABLE TO app_user;
GRANT DELETE ANY TABLE TO app_user;

-- Create Default Role
CREATE ROLE app_user_role;
GRANT app_user_role TO app_user;

COMMIT;
