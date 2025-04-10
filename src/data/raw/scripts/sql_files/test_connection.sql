-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREE

-- Set display format for better readability
SET LINESIZE 100
SET PAGESIZE 50

-- Test basic connection
SELECT SYSDATE FROM dual;

-- Show current user and database name
SELECT USER, SYS_CONTEXT('USERENV', 'DB_NAME') as database_name 
FROM dual;

-- List all tables in the current schema
SELECT table_name 
FROM user_tables 
ORDER BY table_name;

-- Check if our specific tables exist
SELECT table_name 
FROM user_tables 
WHERE table_name IN (
    'FINANCIAL_STATEMENTS',
    'BUDGETS',
    'CASH_FLOW',
    'WATER_QUALITY_METRICS',
    'SYSTEM_PERFORMANCE_METRICS',
    'ENERGY_METRICS',
    'EMPLOYEES',
    'PERFORMANCE_REVIEWS',
    'TRAINING_RECORDS',
    'EQUIPMENT',
    'MAINTENANCE_RECORDS',
    'WORK_ORDERS'
);

-- Show table structures
DESC FINANCIAL_STATEMENTS;
DESC BUDGETS;
DESC CASH_FLOW;

-- Check if we have any data in our tables
SELECT COUNT(*) as record_count FROM FINANCIAL_STATEMENTS;
SELECT COUNT(*) as record_count FROM BUDGETS;
SELECT COUNT(*) as record_count FROM CASH_FLOW;

-- Show database version and character set
SELECT * FROM v$version;
SELECT * FROM nls_database_parameters WHERE parameter LIKE '%CHARACTERSET%';

-- Exit SQL*Plus
EXIT; 