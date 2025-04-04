SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Create external tables for data loading
CREATE TABLE ext_water_utilities_assets (
    asset_id VARCHAR2(50),
    name VARCHAR2(100),
    type VARCHAR2(50),
    category VARCHAR2(50),
    manufacturer VARCHAR2(100),
    model_number VARCHAR2(50),
    serial_number VARCHAR2(50),
    installation_date VARCHAR2(10),
    expected_lifetime_hours NUMBER,
    expected_lifetime_years NUMBER,
    purchase_cost NUMBER,
    replacement_cost NUMBER,
    warranty_expiration VARCHAR2(10),
    maintenance_interval NUMBER,
    standards CLOB,
    failure_modes CLOB,
    condition_score NUMBER,
    criticality_rating NUMBER,
    operational_status VARCHAR2(20),
    firmware_version VARCHAR2(20),
    parent_asset_id VARCHAR2(50),
    location CLOB
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('water_utilities_assets.csv')
)
REJECT LIMIT UNLIMITED;

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
INSERT INTO water_utilities_assets (
    asset_id, name, type, category, manufacturer, model_number,
    installation_date, operational_status, location
)
SELECT 
    asset_id,
    name,
    type,
    'Water Treatment' as category,
    manufacturer,
    model_number,
    installation_date,
    operational_status,
    location
FROM ext_water_utilities_assets;

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
SELECT 'water_utilities_assets: ' || COUNT(*) as count FROM water_utilities_assets;
SELECT 'workforce_attendance: ' || COUNT(*) as count FROM workforce_attendance;
SELECT 'industrial_iot_data: ' || COUNT(*) as count FROM industrial_iot_data;

-- Drop external tables
DROP TABLE ext_water_utilities_assets;
DROP TABLE ext_workforce_attendance;
DROP TABLE ext_industrial_iot_data;

EXIT; 