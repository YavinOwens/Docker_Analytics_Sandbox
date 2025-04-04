SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Disable all foreign key constraints
BEGIN
  FOR r IN (SELECT constraint_name, table_name FROM user_constraints 
            WHERE constraint_type = 'R' 
            AND table_name IN ('INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY')) LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || r.table_name || 
                     ' DISABLE CONSTRAINT ' || r.constraint_name;
  END LOOP;
END;
/

-- Create directory for data files
CREATE OR REPLACE DIRECTORY DATA_DIR AS '/opt/oracle/scripts/data';

-- Create external table for industrial_iot_data
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ext_industrial_iot_data';
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;
/

CREATE TABLE ext_industrial_iot_data (
    line VARCHAR2(4000)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DATA_DIR
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY '\n'
        FIELDS TERMINATED BY '\n'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('industrial_iot_data.csv')
);

-- Create staging table
CREATE TABLE industrial_iot_data_staging (
    device_id VARCHAR2(50),
    device_name VARCHAR2(100),
    device_type VARCHAR2(50),
    location VARCHAR2(50),
    status VARCHAR2(20),
    last_reading NUMBER,
    reading_timestamp TIMESTAMP,
    battery_level NUMBER,
    signal_strength NUMBER
);

-- Load data into staging table
INSERT INTO industrial_iot_data_staging
WITH parsed_data AS (
    SELECT 
        REGEXP_SUBSTR(line, '[^,]+', 1, 1) as device_id,
        REGEXP_SUBSTR(line, '[^,]+', 1, 2) as device_name,
        REGEXP_SUBSTR(line, '[^,]+', 1, 3) as device_type,
        REGEXP_SUBSTR(line, '[^,]+', 1, 4) as location,
        REGEXP_SUBSTR(line, '[^,]+', 1, 5) as status,
        REGEXP_SUBSTR(line, '[^,]+', 1, 6) as last_reading,
        REGEXP_SUBSTR(line, '[^,]+', 1, 7) as reading_timestamp,
        REGEXP_SUBSTR(line, '[^,]+', 1, 8) as battery_level,
        REGEXP_SUBSTR(line, '[^,]+', 1, 9) as signal_strength
    FROM ext_industrial_iot_data
    WHERE line NOT LIKE '%device_id%'
)
SELECT 
    device_id,
    device_name,
    device_type,
    location,
    status,
    TO_NUMBER(last_reading),
    TO_TIMESTAMP(reading_timestamp, 'YYYY-MM-DD HH24:MI:SS.FF'),
    TO_NUMBER(battery_level),
    TO_NUMBER(signal_strength)
FROM parsed_data;

COMMIT;

-- Load data from staging table to final table
INSERT INTO industrial_iot_data
SELECT * FROM industrial_iot_data_staging;

COMMIT;

-- Drop staging table
DROP TABLE industrial_iot_data_staging;

-- Verify data loading
SELECT COUNT(*) as row_count FROM industrial_iot_data;

-- Create external table for industrial_maintenance
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ext_industrial_maintenance';
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;
/

CREATE TABLE ext_industrial_maintenance (
    line VARCHAR2(4000)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DATA_DIR
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY '\n'
        FIELDS TERMINATED BY '\n'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('industrial_maintenance.csv')
);

-- Create staging table
CREATE TABLE industrial_maintenance_staging (
    maintenance_id VARCHAR2(50),
    device_id VARCHAR2(50),
    maintenance_type VARCHAR2(50),
    scheduled_date DATE,
    completed_date DATE,
    status VARCHAR2(20),
    technician_id VARCHAR2(50),
    description VARCHAR2(500),
    parts_replaced VARCHAR2(500)
);

-- Load data into staging table
INSERT INTO industrial_maintenance_staging
WITH parsed_data AS (
    SELECT 
        REGEXP_SUBSTR(line, '[^,]+', 1, 1) as maintenance_id,
        REGEXP_SUBSTR(line, '[^,]+', 1, 2) as device_id,
        REGEXP_SUBSTR(line, '[^,]+', 1, 3) as maintenance_type,
        REGEXP_SUBSTR(line, '[^,]+', 1, 4) as scheduled_date,
        REGEXP_SUBSTR(line, '[^,]+', 1, 5) as completed_date,
        REGEXP_SUBSTR(line, '[^,]+', 1, 6) as status,
        REGEXP_SUBSTR(line, '[^,]+', 1, 7) as technician_id,
        REGEXP_SUBSTR(line, '[^,]+', 1, 8) as description,
        REGEXP_SUBSTR(line, '[^,]+', 1, 9) as parts_replaced
    FROM ext_industrial_maintenance
    WHERE line NOT LIKE '%maintenance_id%'
)
SELECT 
    maintenance_id,
    device_id,
    maintenance_type,
    TO_DATE(scheduled_date, 'YYYY-MM-DD'),
    TO_DATE(completed_date, 'YYYY-MM-DD'),
    status,
    technician_id,
    description,
    parts_replaced
FROM parsed_data;

COMMIT;

-- Load data from staging table to final table
INSERT INTO industrial_maintenance
SELECT * FROM industrial_maintenance_staging;

COMMIT;

-- Drop staging table
DROP TABLE industrial_maintenance_staging;

-- Verify data loading
SELECT COUNT(*) as row_count FROM industrial_maintenance;

-- Create external table for industrial_safety
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ext_industrial_safety';
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;
/

CREATE TABLE ext_industrial_safety (
    line VARCHAR2(4000)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY DATA_DIR
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY '\n'
        FIELDS TERMINATED BY '\n'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('industrial_safety.csv')
);

-- Create staging table
CREATE TABLE industrial_safety_staging (
    safety_id VARCHAR2(50),
    device_id VARCHAR2(50),
    incident_type VARCHAR2(50),
    incident_date DATE,
    severity_level VARCHAR2(20),
    description VARCHAR2(500),
    action_taken VARCHAR2(500),
    reported_by VARCHAR2(100),
    status VARCHAR2(20)
);

-- Load data into staging table
INSERT INTO industrial_safety_staging
WITH parsed_data AS (
    SELECT 
        REGEXP_SUBSTR(line, '[^,]+', 1, 1) as safety_id,
        REGEXP_SUBSTR(line, '[^,]+', 1, 2) as device_id,
        REGEXP_SUBSTR(line, '[^,]+', 1, 3) as incident_type,
        REGEXP_SUBSTR(line, '[^,]+', 1, 4) as incident_date,
        REGEXP_SUBSTR(line, '[^,]+', 1, 5) as severity_level,
        REGEXP_SUBSTR(line, '[^,]+', 1, 6) as description,
        REGEXP_SUBSTR(line, '[^,]+', 1, 7) as action_taken,
        REGEXP_SUBSTR(line, '[^,]+', 1, 8) as reported_by,
        REGEXP_SUBSTR(line, '[^,]+', 1, 9) as status
    FROM ext_industrial_safety
    WHERE line NOT LIKE '%safety_id%'
)
SELECT 
    safety_id,
    device_id,
    incident_type,
    TO_DATE(incident_date, 'YYYY-MM-DD'),
    severity_level,
    description,
    action_taken,
    reported_by,
    status
FROM parsed_data;

COMMIT;

-- Load data from staging table to final table
INSERT INTO industrial_safety
SELECT * FROM industrial_safety_staging;

COMMIT;

-- Drop staging table
DROP TABLE industrial_safety_staging;

-- Verify data loading
SELECT COUNT(*) as row_count FROM industrial_safety;

-- Verify final row counts
SELECT table_name, num_rows as row_count
FROM user_tables
WHERE table_name IN ('INDUSTRIAL_IOT_DATA', 'INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY');

-- Check for orphaned records
SELECT COUNT(*) as orphaned_count
FROM industrial_maintenance m
WHERE NOT EXISTS (
    SELECT 1 FROM industrial_iot_data i WHERE i.device_id = m.device_id
);

SELECT COUNT(*) as orphaned_count
FROM industrial_safety s
WHERE NOT EXISTS (
    SELECT 1 FROM industrial_iot_data i WHERE i.device_id = s.device_id
);

-- Re-enable all foreign key constraints
BEGIN
  FOR r IN (SELECT constraint_name, table_name FROM user_constraints 
            WHERE constraint_type = 'R' 
            AND table_name IN ('INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY')) LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || r.table_name || 
                     ' ENABLE NOVALIDATE CONSTRAINT ' || r.constraint_name;
  END LOOP;
END;
/

EXIT; 