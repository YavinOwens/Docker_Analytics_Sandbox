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
   EXECUTE IMMEDIATE 'DROP TABLE workforce_attendance CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Create table
CREATE TABLE workforce_attendance (
    attendance_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    attendance_date DATE,
    check_in_time TIMESTAMP,
    check_out_time TIMESTAMP,
    status VARCHAR2(20),
    notes CLOB,
    CONSTRAINT chk_attendance_status CHECK (status IN ('Present', 'Absent', 'Late', 'Early Departure'))
);

-- Load data from CSV
INSERT INTO workforce_attendance (
    attendance_id,
    employee_id,
    attendance_date,
    check_in_time,
    check_out_time,
    status,
    notes
)
SELECT 
    attendance_id,
    employee_id,
    TO_DATE(attendance_date, 'YYYY-MM-DD'),
    TO_TIMESTAMP(check_in_time, 'YYYY-MM-DD HH24:MI:SS.FF'),
    TO_TIMESTAMP(check_out_time, 'YYYY-MM-DD HH24:MI:SS.FF'),
    status,
    notes
FROM EXTERNAL (
    (
        attendance_id VARCHAR2(50),
        employee_id VARCHAR2(50),
        attendance_date VARCHAR2(10),
        check_in_time VARCHAR2(30),
        check_out_time VARCHAR2(30),
        status VARCHAR2(20),
        notes CLOB
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
    LOCATION ('workforce_attendance.csv')
    REJECT LIMIT UNLIMITED
);

-- Commit the changes
COMMIT;

-- Verify data loading
SELECT COUNT(*) as total_records,
       COUNT(DISTINCT employee_id) as unique_employees,
       MIN(attendance_date) as earliest_date,
       MAX(attendance_date) as latest_date,
       COUNT(CASE WHEN status = 'Present' THEN 1 END) as present_count,
       COUNT(CASE WHEN status = 'Absent' THEN 1 END) as absent_count,
       COUNT(CASE WHEN status = 'Late' THEN 1 END) as late_count,
       COUNT(CASE WHEN status = 'Early Departure' THEN 1 END) as early_departure_count
FROM workforce_attendance; 