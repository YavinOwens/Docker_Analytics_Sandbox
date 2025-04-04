SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Check device IDs in industrial_iot_data
SELECT 'Devices in industrial_iot_data: ' || COUNT(*) as count FROM industrial_iot_data;

-- Create external tables for checking
CREATE TABLE ext_industrial_maintenance (
    maintenance_id VARCHAR2(50),
    device_id VARCHAR2(50),
    maintenance_type VARCHAR2(50),
    scheduled_date CHAR(10),
    completed_date CHAR(10),
    status VARCHAR2(20),
    technician_id VARCHAR2(50),
    description VARCHAR2(500),
    parts_replaced VARCHAR2(500)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
        SKIP 1
    )
    LOCATION ('industrial_maintenance.csv')
)
REJECT LIMIT UNLIMITED;

CREATE TABLE ext_industrial_safety (
    safety_id VARCHAR2(50),
    device_id VARCHAR2(50),
    incident_type VARCHAR2(50),
    incident_date CHAR(10),
    severity_level VARCHAR2(20),
    description VARCHAR2(500),
    action_taken VARCHAR2(500),
    reported_by VARCHAR2(50),
    status VARCHAR2(20)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        FIELDS TERMINATED BY ','
        MISSING FIELD VALUES ARE NULL
        SKIP 1
    )
    LOCATION ('industrial_safety.csv')
)
REJECT LIMIT UNLIMITED;

-- Check device IDs in maintenance data that don't exist in industrial_iot_data
SELECT DISTINCT m.device_id
FROM ext_industrial_maintenance m
WHERE NOT EXISTS (
    SELECT 1 FROM industrial_iot_data i 
    WHERE i.device_id = m.device_id
)
AND ROWNUM <= 5;

-- Check device IDs in safety data that don't exist in industrial_iot_data
SELECT DISTINCT s.device_id
FROM ext_industrial_safety s
WHERE NOT EXISTS (
    SELECT 1 FROM industrial_iot_data i 
    WHERE i.device_id = s.device_id
)
AND ROWNUM <= 5;

-- Drop external tables
DROP TABLE ext_industrial_maintenance;
DROP TABLE ext_industrial_safety;

EXIT; 