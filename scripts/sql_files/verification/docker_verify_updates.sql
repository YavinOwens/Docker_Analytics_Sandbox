WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Check if tables exist
SELECT table_name 
FROM user_tables 
WHERE table_name IN (
    'EMPLOYEES',
    'INDUSTRIAL_IOT_DATA',
    'INDUSTRIAL_MAINTENANCE',
    'INDUSTRIAL_PERFORMANCE',
    'INDUSTRIAL_SAFETY',
    'WORKFORCE_ATTENDANCE',
    'WORKFORCE_SKILLS',
    'WORKFORCE_TRAINING',
    'WORKFORCE_SCHEDULING'
);

-- Check table structures
SELECT column_name, data_type, data_length
FROM user_tab_columns
WHERE table_name = 'EMPLOYEES'
ORDER BY column_id;

-- Check sample data from employees
SELECT employee_id, first_name, last_name, email, department
FROM employees
WHERE ROWNUM <= 5;

-- Check department distribution
SELECT department, COUNT(*) as count
FROM employees
GROUP BY department
ORDER BY department;

-- Check if we need to create missing tables
BEGIN
    FOR r IN (SELECT table_name FROM user_tables) LOOP
        DBMS_OUTPUT.PUT_LINE('Table exists: ' || r.table_name);
    END LOOP;
END;
/

-- Check if we need to run the creation scripts
SELECT 'Tables need to be created' as status
FROM dual
WHERE NOT EXISTS (
    SELECT 1 FROM user_tables 
    WHERE table_name = 'INDUSTRIAL_IOT_DATA'
);

EXIT; 