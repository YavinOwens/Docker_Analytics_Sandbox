WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- First connect as sys to create directory and grant privileges
CONNECT sys/Welcome123@//localhost:1521/FREEPDB1 AS SYSDBA

-- Create external tables for data loading
CREATE OR REPLACE DIRECTORY data_dir AS '/opt/oracle/scripts/data';

-- Grant necessary privileges to app_user
GRANT CREATE DIRECTORY TO app_user;
GRANT READ, WRITE ON DIRECTORY data_dir TO app_user;

-- Switch to app_user context
CONNECT app_user/Welcome123@//localhost:1521/FREEPDB1

-- Create external table for water utilities assets
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

-- Create external table for workforce data
CREATE TABLE ext_workforce_attendance (
    attendance_id VARCHAR2(50),
    employee_id VARCHAR2(50),
    check_in TIMESTAMP,
    check_out TIMESTAMP,
    status VARCHAR2(20),
    notes VARCHAR2(500)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('workforce_attendance.csv')
);

CREATE TABLE ext_workforce_skills (
    skill_id VARCHAR2(50),
    employee_id VARCHAR2(50),
    skill_name VARCHAR2(100),
    proficiency_level VARCHAR2(20),
    certification_date DATE,
    expiry_date DATE
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('workforce_skills.csv')
);

CREATE TABLE ext_workforce_training (
    training_id VARCHAR2(50),
    employee_id VARCHAR2(50),
    training_name VARCHAR2(100),
    training_date DATE,
    completion_status VARCHAR2(20),
    trainer VARCHAR2(100),
    notes VARCHAR2(500)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('workforce_training.csv')
);

CREATE TABLE ext_workforce_scheduling (
    schedule_id VARCHAR2(50),
    employee_id VARCHAR2(50),
    shift_date DATE,
    shift_type VARCHAR2(20),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    department VARCHAR2(50),
    status VARCHAR2(20)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('workforce_scheduling.csv')
);

-- Create external table for industrial data
CREATE TABLE ext_industrial_iot_data (
    device_id VARCHAR2(50),
    device_name VARCHAR2(100),
    device_type VARCHAR2(50),
    location VARCHAR2(100),
    status VARCHAR2(20),
    installation_date DATE,
    last_maintenance_date DATE,
    next_maintenance_date DATE
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('industrial_iot_data.csv')
);

CREATE TABLE ext_industrial_performance (
    performance_id VARCHAR2(50),
    device_id VARCHAR2(50),
    metric_name VARCHAR2(100),
    metric_value NUMBER,
    unit VARCHAR2(20),
    measurement_time TIMESTAMP
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('industrial_performance.csv')
);

CREATE TABLE ext_industrial_maintenance (
    maintenance_id VARCHAR2(50),
    device_id VARCHAR2(50),
    maintenance_type VARCHAR2(50),
    scheduled_date DATE,
    completed_date DATE,
    status VARCHAR2(20),
    description VARCHAR2(500),
    technician_id VARCHAR2(50)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('industrial_maintenance.csv')
);

CREATE TABLE ext_industrial_safety (
    safety_id VARCHAR2(50),
    device_id VARCHAR2(50),
    incident_type VARCHAR2(50),
    description VARCHAR2(500),
    severity VARCHAR2(20),
    incident_date TIMESTAMP,
    status VARCHAR2(20),
    reported_by VARCHAR2(100)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('industrial_safety.csv')
);

-- Load data into main tables
INSERT INTO industrial_iot_data
SELECT * FROM ext_industrial_iot_data;

INSERT INTO industrial_performance
SELECT * FROM ext_industrial_performance;

INSERT INTO industrial_maintenance
SELECT * FROM ext_industrial_maintenance;

INSERT INTO industrial_safety
SELECT * FROM ext_industrial_safety;

INSERT INTO workforce_attendance
SELECT * FROM ext_workforce_attendance;

INSERT INTO workforce_skills
SELECT * FROM ext_workforce_skills;

INSERT INTO workforce_training
SELECT * FROM ext_workforce_training;

INSERT INTO workforce_scheduling
SELECT * FROM ext_workforce_scheduling;

-- Update Ofwat compliance status for all devices
UPDATE industrial_iot_data d
SET ofwat_compliance_status = (
    SELECT water_quality_pkg.check_ofwat_compliance(
        MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
    )
    FROM industrial_performance p
    WHERE p.device_id = d.device_id
    AND p.is_ofwat_metric = 'Y'
),
last_compliance_check = SYSTIMESTAMP,
water_quality_index = (
    SELECT water_quality_pkg.calculate_wqi(
        MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
    )
    FROM industrial_performance p
    WHERE p.device_id = d.device_id
    AND p.is_ofwat_metric = 'Y'
);

-- Generate initial notifications
EXEC generate_compliance_notifications;

-- Verify data loading
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN (
    'INDUSTRIAL_IOT_DATA',
    'INDUSTRIAL_PERFORMANCE',
    'INDUSTRIAL_MAINTENANCE',
    'INDUSTRIAL_SAFETY',
    'WORKFORCE_ATTENDANCE',
    'WORKFORCE_SKILLS',
    'WORKFORCE_TRAINING',
    'WORKFORCE_SCHEDULING',
    'COMPLIANCE_NOTIFICATIONS'
);

-- Check Ofwat compliance status
SELECT 
    ofwat_compliance_status,
    COUNT(*) as device_count,
    AVG(water_quality_index) as avg_water_quality_index
FROM industrial_iot_data
GROUP BY ofwat_compliance_status;

EXIT; 