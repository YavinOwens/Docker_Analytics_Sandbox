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
   EXECUTE IMMEDIATE 'DROP TABLE workforce_training CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Create table
CREATE TABLE workforce_training (
    training_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    training_name VARCHAR2(100),
    training_type VARCHAR2(20),
    start_date DATE,
    end_date DATE,
    status VARCHAR2(20),
    completion_date DATE,
    trainer VARCHAR2(50),
    CONSTRAINT chk_wft_training_type CHECK (training_type IN ('Technical', 'Soft Skills', 'Compliance', 'Safety')),
    CONSTRAINT chk_wft_training_status CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled'))
);

-- Load data from CSV
INSERT INTO workforce_training (
    training_id,
    employee_id,
    training_name,
    training_type,
    start_date,
    end_date,
    status,
    completion_date,
    trainer
)
SELECT 
    training_id,
    employee_id,
    training_name,
    training_type,
    TO_DATE(start_date, 'YYYY-MM-DD'),
    TO_DATE(end_date, 'YYYY-MM-DD'),
    status,
    TO_DATE(completion_date, 'YYYY-MM-DD'),
    trainer
FROM EXTERNAL (
    (
        training_id VARCHAR2(50),
        employee_id VARCHAR2(50),
        training_name VARCHAR2(100),
        training_type VARCHAR2(20),
        start_date VARCHAR2(10),
        end_date VARCHAR2(10),
        status VARCHAR2(20),
        completion_date VARCHAR2(10),
        trainer VARCHAR2(50)
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
    LOCATION ('workforce_training.csv')
    REJECT LIMIT UNLIMITED
);

-- Commit the changes
COMMIT;

-- Verify data loading
SELECT COUNT(*) as total_records,
       COUNT(DISTINCT employee_id) as unique_employees,
       COUNT(DISTINCT trainer) as unique_trainers,
       MIN(start_date) as earliest_start,
       MAX(end_date) as latest_end,
       COUNT(CASE WHEN status = 'Scheduled' THEN 1 END) as scheduled_count,
       COUNT(CASE WHEN status = 'In Progress' THEN 1 END) as in_progress_count,
       COUNT(CASE WHEN status = 'Completed' THEN 1 END) as completed_count,
       COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) as cancelled_count,
       COUNT(CASE WHEN training_type = 'Technical' THEN 1 END) as technical_count,
       COUNT(CASE WHEN training_type = 'Soft Skills' THEN 1 END) as soft_skills_count,
       COUNT(CASE WHEN training_type = 'Compliance' THEN 1 END) as compliance_count,
       COUNT(CASE WHEN training_type = 'Safety' THEN 1 END) as safety_count
FROM workforce_training; 