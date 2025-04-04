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
   EXECUTE IMMEDIATE 'DROP TABLE workforce_skills CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Create table
CREATE TABLE workforce_skills (
    skill_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    skill_name VARCHAR2(100),
    proficiency_level VARCHAR2(20),
    certification_date DATE,
    expiry_date DATE,
    certified_by VARCHAR2(50),
    CONSTRAINT chk_wfs_proficiency_level CHECK (proficiency_level IN ('Beginner', 'Intermediate', 'Advanced', 'Expert'))
);

-- Load data from CSV
INSERT INTO workforce_skills (
    skill_id,
    employee_id,
    skill_name,
    proficiency_level,
    certification_date,
    expiry_date,
    certified_by
)
SELECT 
    skill_id,
    employee_id,
    skill_name,
    proficiency_level,
    TO_DATE(certification_date, 'YYYY-MM-DD'),
    TO_DATE(expiry_date, 'YYYY-MM-DD'),
    certified_by
FROM EXTERNAL (
    (
        skill_id VARCHAR2(50),
        employee_id VARCHAR2(50),
        skill_name VARCHAR2(100),
        proficiency_level VARCHAR2(20),
        certification_date VARCHAR2(10),
        expiry_date VARCHAR2(10),
        certified_by VARCHAR2(50)
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
    LOCATION ('workforce_skills.csv')
    REJECT LIMIT UNLIMITED
);

-- Commit the changes
COMMIT;

-- Verify data loading
SELECT COUNT(*) as total_records,
       COUNT(DISTINCT employee_id) as unique_employees,
       COUNT(DISTINCT skill_name) as unique_skills,
       COUNT(DISTINCT certified_by) as unique_certifiers,
       MIN(certification_date) as earliest_cert,
       MAX(expiry_date) as latest_expiry,
       COUNT(CASE WHEN proficiency_level = 'Beginner' THEN 1 END) as beginner_count,
       COUNT(CASE WHEN proficiency_level = 'Intermediate' THEN 1 END) as intermediate_count,
       COUNT(CASE WHEN proficiency_level = 'Advanced' THEN 1 END) as advanced_count,
       COUNT(CASE WHEN proficiency_level = 'Expert' THEN 1 END) as expert_count
FROM workforce_skills; 