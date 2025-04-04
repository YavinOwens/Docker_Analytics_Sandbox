-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Create directory for data loading
CREATE OR REPLACE DIRECTORY data_dir AS '/opt/oracle/data';
GRANT READ ON DIRECTORY data_dir TO PUBLIC;

-- Kill any existing sessions that might be locking the table
DECLARE
    v_sid NUMBER;
    v_serial NUMBER;
BEGIN
    FOR r IN (SELECT sid, serial# FROM v$session WHERE username = 'SYSTEM' AND program LIKE '%sqlplus%') LOOP
        BEGIN
            EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || r.sid || ',' || r.serial# || ''' IMMEDIATE';
        EXCEPTION
            WHEN OTHERS THEN
                NULL;
        END;
    END LOOP;
END;
/

-- Wait a moment for sessions to be killed
EXECUTE DBMS_LOCK.SLEEP(2);

-- Drop table if it exists
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE water_utility_assets CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Create table
CREATE TABLE water_utility_assets (
    asset_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    asset_type VARCHAR2(50) NOT NULL,
    location VARCHAR2(200) NOT NULL,
    status VARCHAR2(20) NOT NULL,
    installation_date DATE NOT NULL,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    manufacturer VARCHAR2(100),
    model_number VARCHAR2(50),
    serial_number VARCHAR2(50),
    capacity NUMBER,
    unit_of_measure VARCHAR2(20),
    notes CLOB
);

-- Load data from CSV
INSERT INTO water_utility_assets (
    asset_type,
    location,
    status,
    installation_date,
    last_maintenance_date,
    next_maintenance_date,
    manufacturer,
    model_number,
    serial_number,
    capacity,
    unit_of_measure,
    notes
)
SELECT 
    asset_type,
    location,
    status,
    TO_DATE(installation_date, 'YYYY-MM-DD'),
    TO_DATE(last_maintenance_date, 'YYYY-MM-DD'),
    TO_DATE(next_maintenance_date, 'YYYY-MM-DD'),
    manufacturer,
    model_number,
    serial_number,
    capacity,
    unit_of_measure,
    notes
FROM ext_water_utility_assets;

-- Commit the changes
COMMIT;

-- Verify data loading
SELECT COUNT(*) as total_assets,
       COUNT(DISTINCT asset_type) as unique_asset_types,
       MIN(installation_date) as earliest_installation,
       MAX(installation_date) as latest_installation
FROM water_utility_assets; 