-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Create directory for data loading
CREATE OR REPLACE DIRECTORY data_dir AS '/opt/oracle/data';
GRANT READ ON DIRECTORY data_dir TO PUBLIC;

-- Drop table if it exists
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE workforce_scheduling CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Create table
CREATE TABLE workforce_scheduling (
    schedule_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    shift_date DATE,
    shift_type VARCHAR2(20),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    department VARCHAR2(50),
    status VARCHAR2(20),
    CONSTRAINT chk_shift_type CHECK (shift_type IN ('Morning', 'Afternoon', 'Night', 'Flexible')),
    CONSTRAINT chk_schedule_status CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'In Progress'))
);

-- Load data from CSV
INSERT INTO workforce_scheduling (
    schedule_id,
    employee_id,
    shift_date,
    shift_type,
    start_time,
    end_time,
    department,
    status
)
SELECT 
    schedule_id,
    employee_id,
    TO_DATE(shift_date, 'YYYY-MM-DD'),
    shift_type,
    TO_TIMESTAMP(start_time, 'YYYY-MM-DD HH24:MI:SS.FF'),
    TO_TIMESTAMP(end_time, 'YYYY-MM-DD HH24:MI:SS.FF'),
    department,
    status
FROM EXTERNAL (
    (
        schedule_id VARCHAR2(50),
        employee_id VARCHAR2(50),
        shift_date VARCHAR2(10),
        shift_type VARCHAR2(20),
        start_time VARCHAR2(30),
        end_time VARCHAR2(30),
        department VARCHAR2(50),
        status VARCHAR2(20)
    )
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
    LOCATION ('workforce_scheduling.csv')
    REJECT LIMIT UNLIMITED
);

-- Commit the changes
COMMIT;

-- Verify data loading
SELECT COUNT(*) as total_records,
       COUNT(DISTINCT employee_id) as unique_employees,
       COUNT(DISTINCT department) as unique_departments,
       MIN(shift_date) as earliest_date,
       MAX(shift_date) as latest_date,
       COUNT(CASE WHEN status = 'Scheduled' THEN 1 END) as scheduled_count,
       COUNT(CASE WHEN status = 'Completed' THEN 1 END) as completed_count,
       COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) as cancelled_count,
       COUNT(CASE WHEN status = 'In Progress' THEN 1 END) as in_progress_count,
       COUNT(CASE WHEN shift_type = 'Morning' THEN 1 END) as morning_shifts,
       COUNT(CASE WHEN shift_type = 'Afternoon' THEN 1 END) as afternoon_shifts,
       COUNT(CASE WHEN shift_type = 'Night' THEN 1 END) as night_shifts,
       COUNT(CASE WHEN shift_type = 'Flexible' THEN 1 END) as flexible_shifts
FROM workforce_scheduling; 