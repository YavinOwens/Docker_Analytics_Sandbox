SET SERVEROUTPUT ON
SET LINESIZE 1000
SET PAGESIZE 1000

-- Check all constraints referencing industrial_iot_data
SELECT a.table_name, a.constraint_name, a.constraint_type, b.column_name, c.table_name as referenced_table
FROM user_constraints a
JOIN user_cons_columns b ON a.constraint_name = b.constraint_name
LEFT JOIN user_constraints c ON a.r_constraint_name = c.constraint_name
WHERE c.table_name = 'INDUSTRIAL_IOT_DATA'
OR a.table_name = 'INDUSTRIAL_IOT_DATA';

-- Check all triggers referencing industrial_iot_data
SELECT trigger_name, table_name, trigger_type, triggering_event
FROM user_triggers
WHERE table_name = 'INDUSTRIAL_IOT_DATA';

-- Check all views referencing industrial_iot_data
SELECT view_name, text
FROM user_views
WHERE text LIKE '%INDUSTRIAL_IOT_DATA%';

EXIT; 