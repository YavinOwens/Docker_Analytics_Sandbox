-- Load Industrial Safety Data
SET DEFINE OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;

-- Truncate existing data
TRUNCATE TABLE industrial_safety;

-- Load data from CSV
INSERT INTO industrial_safety (
    safety_id,
    device_id,
    incident_type,
    incident_date,
    severity_level,
    description,
    action_taken,
    reported_by,
    status
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
FROM EXTERNAL (
    (
        safety_id VARCHAR2(20),
        device_id VARCHAR2(20),
        incident_type VARCHAR2(20),
        incident_date VARCHAR2(10),
        severity_level VARCHAR2(20),
        description VARCHAR2(200),
        action_taken VARCHAR2(200),
        reported_by VARCHAR2(20),
        status VARCHAR2(20)
    )
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        CHARACTERSET AL32UTF8
        STRING SIZES ARE IN CHARACTERS
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"' AND '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('transformed_data/industrial_data/industrial_safety.csv')
    REJECT LIMIT UNLIMITED
) SAMPLE 100 PERCENT; 