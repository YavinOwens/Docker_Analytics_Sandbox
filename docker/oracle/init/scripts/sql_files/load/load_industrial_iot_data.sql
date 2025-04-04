-- Load Industrial IoT Data
SET DEFINE OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;

-- Truncate existing data
TRUNCATE TABLE industrial_iot_data;

-- Load data from CSV
INSERT INTO industrial_iot_data (
    device_id,
    device_name,
    device_type,
    location,
    status,
    last_reading,
    reading_timestamp,
    battery_level,
    signal_strength
)
SELECT 
    device_id,
    device_name,
    device_type,
    location,
    status,
    last_reading,
    TO_TIMESTAMP(reading_timestamp, 'YYYY-MM-DD HH24:MI:SS.FF'),
    battery_level,
    signal_strength
FROM EXTERNAL (
    (
        device_id VARCHAR2(20),
        device_name VARCHAR2(50),
        device_type VARCHAR2(20),
        location VARCHAR2(50),
        status VARCHAR2(20),
        last_reading NUMBER,
        reading_timestamp VARCHAR2(30),
        battery_level NUMBER,
        signal_strength NUMBER
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
    LOCATION ('transformed_data/industrial_data/industrial_iot_data.csv')
    REJECT LIMIT UNLIMITED
) SAMPLE 100 PERCENT; 