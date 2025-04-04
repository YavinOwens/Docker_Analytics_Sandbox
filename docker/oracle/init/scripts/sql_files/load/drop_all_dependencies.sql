SET SERVEROUTPUT ON
SET FEEDBACK ON

-- First, drop all foreign key constraints
BEGIN
  FOR c IN (
    SELECT table_name, constraint_name 
    FROM user_constraints 
    WHERE constraint_type = 'R'
    AND table_name IN ('INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY', 'INDUSTRIAL_PERFORMANCE')
  ) LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || ' DROP CONSTRAINT ' || c.constraint_name;
    DBMS_OUTPUT.PUT_LINE('Dropped constraint: ' || c.constraint_name || ' from table: ' || c.table_name);
  END LOOP;
END;
/

-- Now drop the tables in the correct order
DROP TABLE industrial_safety;
DROP TABLE industrial_maintenance;
DROP TABLE industrial_performance;
DROP TABLE industrial_iot_data;

-- Verify tables are dropped
SELECT table_name 
FROM user_tables 
WHERE table_name IN ('INDUSTRIAL_IOT_DATA', 'INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY', 'INDUSTRIAL_PERFORMANCE');

EXIT; 