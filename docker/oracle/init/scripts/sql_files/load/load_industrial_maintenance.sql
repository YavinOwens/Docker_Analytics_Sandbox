-- Load Industrial Maintenance Data
SET DEFINE OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;

-- Truncate existing data
TRUNCATE TABLE industrial_maintenance;

-- Load data from CSV
INSERT INTO industrial_maintenance (
    maintenance_id,
    device_id,
    maintenance_type,
    scheduled_date,
    completed_date,
    status,
    technician_id,
    description,
    parts_replaced
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
FROM EXTERNAL (
    (
        maintenance_id VARCHAR2(20),
        device_id VARCHAR2(20),
        maintenance_type VARCHAR2(20),
        scheduled_date VARCHAR2(10),
        completed_date VARCHAR2(10),
        status VARCHAR2(20),
        technician_id VARCHAR2(20),
        description VARCHAR2(200),
        parts_replaced VARCHAR2(200)
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
    LOCATION ('transformed_data/industrial_data/industrial_maintenance.csv')
    REJECT LIMIT UNLIMITED
) SAMPLE 100 PERCENT; 