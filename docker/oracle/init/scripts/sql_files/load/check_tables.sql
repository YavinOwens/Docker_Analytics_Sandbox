SET ECHO OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING OFF

SELECT 'Tables in database:' FROM dual;
SELECT object_name FROM user_objects WHERE object_type = 'TABLE';

SELECT 'Row counts:' FROM dual;
SELECT 'water_utility_assets: ' || COUNT(*) FROM water_utility_assets;
SELECT 'workforce_attendance: ' || COUNT(*) FROM workforce_attendance;
SELECT 'industrial_iot_data: ' || COUNT(*) FROM industrial_iot_data;

SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Check table structures
SELECT table_name, column_name, data_type, data_length
FROM user_tab_columns
WHERE table_name IN ('INDUSTRIAL_IOT_DATA', 'INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY')
ORDER BY table_name, column_id;

-- Check constraints
SELECT table_name, constraint_name, constraint_type, search_condition
FROM user_constraints
WHERE table_name IN ('INDUSTRIAL_IOT_DATA', 'INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY')
ORDER BY table_name;

-- Check constraint columns
SELECT a.table_name, a.constraint_name, a.column_name
FROM user_cons_columns a
JOIN user_constraints b ON a.constraint_name = b.constraint_name
WHERE a.table_name IN ('INDUSTRIAL_IOT_DATA', 'INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY')
ORDER BY a.table_name, a.constraint_name;

EXIT; 