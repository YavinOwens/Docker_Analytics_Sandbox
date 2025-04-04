-- Load Workforce Leave Data
SET DEFINE OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;

-- Truncate existing data
TRUNCATE TABLE workforce_leave;

-- Load data from CSV
INSERT INTO workforce_leave (
    leave_id,
    employee_id,
    leave_type,
    start_date,
    end_date,
    status,
    approved_by,
    reason
)
SELECT 
    leave_id,
    employee_id,
    leave_type,
    TO_DATE(start_date, 'YYYY-MM-DD'),
    TO_DATE(end_date, 'YYYY-MM-DD'),
    status,
    approved_by,
    reason
FROM EXTERNAL (
    (
        leave_id VARCHAR2(20),
        employee_id VARCHAR2(20),
        leave_type VARCHAR2(20),
        start_date VARCHAR2(10),
        end_date VARCHAR2(10),
        status VARCHAR2(20),
        approved_by VARCHAR2(20),
        reason VARCHAR2(200)
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
    LOCATION ('transformed_data/workforce_data/workforce_leave.csv')
    REJECT LIMIT UNLIMITED
) SAMPLE 100 PERCENT; 