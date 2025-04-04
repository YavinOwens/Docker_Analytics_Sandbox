-- Load Industrial Performance Data
SET DEFINE OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;

-- Truncate existing data
TRUNCATE TABLE industrial_performance;

-- Load data from CSV
INSERT INTO industrial_performance (
    performance_id,
    device_id,
    metric_name,
    metric_value,
    measurement_date,
    measurement_time,
    unit,
    status
)
SELECT 
    performance_id,
    device_id,
    metric_name,
    metric_value,
    TO_DATE(measurement_date, 'YYYY-MM-DD'),
    TO_TIMESTAMP(measurement_time, 'YYYY-MM-DD HH24:MI:SS.FF'),
    unit,
    status
FROM EXTERNAL (
    (
        performance_id VARCHAR2(20),
        device_id VARCHAR2(20),
        metric_name VARCHAR2(50),
        metric_value NUMBER,
        measurement_date VARCHAR2(10),
        measurement_time VARCHAR2(30),
        unit VARCHAR2(10),
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
    LOCATION ('transformed_data/industrial_data/industrial_performance.csv')
    REJECT LIMIT UNLIMITED
) SAMPLE 100 PERCENT; 