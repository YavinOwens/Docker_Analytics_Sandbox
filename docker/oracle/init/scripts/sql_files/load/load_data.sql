-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREE

-- Set display format
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Drop existing directory if it exists
DROP DIRECTORY data_dir;

-- Create directory for CSV files
CREATE OR REPLACE DIRECTORY data_dir AS '/opt/oracle/data';

-- Grant read permissions on directory
GRANT READ ON DIRECTORY data_dir TO PUBLIC;

-- Drop existing tables if they exist
BEGIN
   FOR cur_rec IN (SELECT table_name FROM user_tables 
                   WHERE table_name IN ('WATER_UTILITY_ASSETS',
                                      'WORKFORCE_ATTENDANCE',
                                      'INDUSTRIAL_IOT_DATA',
                                      'EXT_WATER_UTILITY_ASSETS',
                                      'EXT_WORKFORCE_ATTENDANCE',
                                      'EXT_INDUSTRIAL_IOT_DATA'))
   LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || cur_rec.table_name || ' CASCADE CONSTRAINTS';
   END LOOP;
END;
/

-- Create external tables for data loading
CREATE TABLE ext_water_utility_assets (
    asset_type VARCHAR2(50),
    location VARCHAR2(200),
    status VARCHAR2(20),
    installation_date VARCHAR2(10),
    last_maintenance_date VARCHAR2(10),
    next_maintenance_date VARCHAR2(10),
    manufacturer VARCHAR2(100),
    model_number VARCHAR2(50),
    serial_number VARCHAR2(50),
    capacity NUMBER,
    unit_of_measure VARCHAR2(20),
    notes CLOB
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET AL32UTF8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('water_utility_assets.csv')
    REJECT LIMIT UNLIMITED
);

CREATE TABLE ext_workforce_attendance (
    attendance_id VARCHAR2(50),
    employee_id VARCHAR2(50),
    attendance_date CHAR(10),
    check_in_time CHAR(19),
    check_out_time CHAR(19),
    status VARCHAR2(20),
    notes VARCHAR2(500)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('workforce_attendance.csv')
)
REJECT LIMIT UNLIMITED;

CREATE TABLE ext_industrial_iot_data (
    device_id VARCHAR2(50),
    device_name VARCHAR2(100),
    device_type VARCHAR2(50),
    location VARCHAR2(100),
    status VARCHAR2(20),
    last_reading NUMBER,
    reading_timestamp CHAR(19),
    battery_level NUMBER,
    signal_strength NUMBER
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('industrial_iot_data.csv')
)
REJECT LIMIT UNLIMITED;

-- Insert data into existing tables
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

INSERT INTO workforce_attendance (
    attendance_id, employee_id, attendance_date, check_in_time,
    check_out_time, status, notes
)
SELECT 
    attendance_id,
    employee_id,
    TO_DATE(attendance_date, 'YYYY-MM-DD'),
    TO_TIMESTAMP(check_in_time, 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP(check_out_time, 'YYYY-MM-DD HH24:MI:SS'),
    status,
    notes
FROM ext_workforce_attendance;

INSERT INTO industrial_iot_data (
    device_id, device_name, device_type, location, status,
    last_reading, reading_timestamp, battery_level, signal_strength
)
SELECT 
    device_id,
    device_name,
    device_type,
    location,
    status,
    last_reading,
    TO_TIMESTAMP(reading_timestamp, 'YYYY-MM-DD HH24:MI:SS'),
    battery_level,
    signal_strength
FROM ext_industrial_iot_data;

-- Commit changes
COMMIT;

-- Verify data loading
SELECT 'water_utility_assets: ' || COUNT(*) as count FROM water_utility_assets;
SELECT 'workforce_attendance: ' || COUNT(*) as count FROM workforce_attendance;
SELECT 'industrial_iot_data: ' || COUNT(*) as count FROM industrial_iot_data;

-- Drop external tables
DROP TABLE ext_water_utility_assets;
DROP TABLE ext_workforce_attendance;
DROP TABLE ext_industrial_iot_data;

EXIT;