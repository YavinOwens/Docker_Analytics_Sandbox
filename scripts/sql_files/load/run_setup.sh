#!/bin/bash
sqlplus "sys/Welcome123@//localhost:1521/FREEPDB1 as sysdba" << EOF
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

CREATE OR REPLACE DIRECTORY data_dir AS '/opt/oracle/scripts/data';
GRANT READ ON DIRECTORY data_dir TO app_user;
GRANT WRITE ON DIRECTORY data_dir TO app_user;

EXIT;
EOF 