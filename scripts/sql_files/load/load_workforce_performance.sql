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
   EXECUTE IMMEDIATE 'DROP TABLE workforce_performance CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Create table
CREATE TABLE workforce_performance (
    performance_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    review_date DATE,
    review_type VARCHAR2(20),
    rating NUMBER(4,2),
    feedback CLOB,
    goals_set CLOB,
    reviewed_by VARCHAR2(50),
    CONSTRAINT chk_wfp_review_type CHECK (review_type IN ('Annual', 'Quarterly', 'Monthly', 'Project')),
    CONSTRAINT chk_wfp_rating CHECK (rating >= 0 AND rating <= 5)
);

-- Load data from CSV
INSERT INTO workforce_performance (
    performance_id,
    employee_id,
    review_date,
    review_type,
    rating,
    feedback,
    goals_set,
    reviewed_by
)
SELECT 
    performance_id,
    employee_id,
    TO_DATE(review_date, 'YYYY-MM-DD'),
    review_type,
    TO_NUMBER(rating),
    feedback,
    goals_set,
    reviewed_by
FROM EXTERNAL (
    (
        performance_id VARCHAR2(50),
        employee_id VARCHAR2(50),
        review_date VARCHAR2(10),
        review_type VARCHAR2(20),
        rating VARCHAR2(20),
        feedback CLOB,
        goals_set CLOB,
        reviewed_by VARCHAR2(50)
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
    LOCATION ('workforce_performance.csv')
    REJECT LIMIT UNLIMITED
);

-- Commit the changes
COMMIT;

-- Verify data loading
SELECT COUNT(*) as total_records,
       COUNT(DISTINCT employee_id) as unique_employees,
       COUNT(DISTINCT reviewed_by) as unique_reviewers,
       MIN(review_date) as earliest_review,
       MAX(review_date) as latest_review,
       COUNT(CASE WHEN review_type = 'Annual' THEN 1 END) as annual_reviews,
       COUNT(CASE WHEN review_type = 'Quarterly' THEN 1 END) as quarterly_reviews,
       COUNT(CASE WHEN review_type = 'Monthly' THEN 1 END) as monthly_reviews,
       COUNT(CASE WHEN review_type = 'Project' THEN 1 END) as project_reviews,
       ROUND(AVG(rating), 2) as avg_rating,
       MIN(rating) as min_rating,
       MAX(rating) as max_rating
FROM workforce_performance; 