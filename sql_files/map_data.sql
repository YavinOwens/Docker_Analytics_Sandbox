-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREE

-- Set display format
SET LINESIZE 1000
SET PAGESIZE 1000

-- Drop existing directory if it exists
DROP DIRECTORY data_dir;

-- Create directory for CSV files
CREATE OR REPLACE DIRECTORY data_dir AS '/opt/oracle/data';

-- Grant read permissions on directory
GRANT READ ON DIRECTORY data_dir TO PUBLIC;

-- Clear existing data
TRUNCATE TABLE water_utilities_assets;
TRUNCATE TABLE water_utilities_work_orders;
TRUNCATE TABLE ofwat_results;
TRUNCATE TABLE capex_projects;
TRUNCATE TABLE pulse_surveys;
TRUNCATE TABLE employees;
TRUNCATE TABLE performance_reviews;

-- Load data into water_utilities_assets
INSERT INTO water_utilities_assets (
    asset_name, asset_type, location, installation_date,
    status, last_maintenance_date, next_maintenance_date
)
SELECT 
    asset_name,
    asset_type,
    location,
    TO_DATE(installation_date, 'YYYY-MM-DD'),
    status,
    TO_DATE(last_maintenance_date, 'YYYY-MM-DD'),
    TO_DATE(next_maintenance_date, 'YYYY-MM-DD')
FROM EXTERNAL (
    (asset_name CHAR(200),
     asset_type CHAR(100),
     location CHAR(200),
     installation_date CHAR(10),
     status CHAR(50),
     last_maintenance_date CHAR(10),
     next_maintenance_date CHAR(10))
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET AL32UTF8
        BADFILE data_dir:'assets_bad.log'
        LOGFILE data_dir:'assets_load.log'
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('water_utilities_assets.csv')
    REJECT LIMIT UNLIMITED
);

-- Load data into water_utilities_work_orders
INSERT INTO water_utilities_work_orders (
    asset_id, work_order_type, priority, status,
    description, assigned_to, created_date, completed_date
)
SELECT 
    TO_NUMBER(asset_id),
    work_order_type,
    priority,
    status,
    description,
    assigned_to,
    TO_DATE(created_date, 'YYYY-MM-DD'),
    TO_DATE(completed_date, 'YYYY-MM-DD')
FROM EXTERNAL (
    (asset_id CHAR(10),
     work_order_type CHAR(100),
     priority CHAR(50),
     status CHAR(50),
     description CHAR(1000),
     assigned_to CHAR(200),
     created_date CHAR(10),
     completed_date CHAR(10))
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET AL32UTF8
        BADFILE data_dir:'work_orders_bad.log'
        LOGFILE data_dir:'work_orders_load.log'
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('water_utilities_work_orders.csv')
    REJECT LIMIT UNLIMITED
);

-- Load data into ofwat_results
INSERT INTO ofwat_results (
    metric_name, target_value, actual_value,
    reporting_period, status
)
SELECT 
    'Water Quality',
    TO_NUMBER(water_quality_score),
    TO_NUMBER(water_quality_score),
    TO_DATE(SUBSTR(quarter, 1, 4) || '-' || 
            LPAD(SUBSTR(quarter, 7, 1) * 3 - 2, 2, '0') || '-01', 'YYYY-MM-DD'),
    'APPROVED'
FROM EXTERNAL (
    (quarter CHAR(10),
     water_quality_score CHAR(10))
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET AL32UTF8
        BADFILE data_dir:'ofwat_results_bad.log'
        LOGFILE data_dir:'ofwat_results_load.log'
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('ofwat_results.csv')
    REJECT LIMIT UNLIMITED
);

-- Load data into capex_projects
INSERT INTO capex_projects (
    project_name, project_type, budget_amount,
    spent_amount, start_date, end_date, status
)
SELECT 
    project_name,
    project_type,
    TO_NUMBER(REPLACE(REPLACE(total_budget, '$', ''), ',', '')),
    TO_NUMBER(REPLACE(REPLACE(actual_cost, '$', ''), ',', '')),
    TO_DATE(start_date, 'YYYY-MM-DD'),
    TO_DATE(actual_end_date, 'YYYY-MM-DD'),
    status
FROM EXTERNAL (
    (project_name CHAR(200),
     project_type CHAR(100),
     total_budget CHAR(20),
     actual_cost CHAR(20),
     start_date CHAR(10),
     actual_end_date CHAR(10),
     status CHAR(50))
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET AL32UTF8
        BADFILE data_dir:'capex_projects_bad.log'
        LOGFILE data_dir:'capex_projects_load.log'
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('capex_projects.csv')
    REJECT LIMIT UNLIMITED
);

-- Load data into pulse_surveys
INSERT INTO pulse_surveys (
    survey_id, survey_date, department, response_rate,
    engagement_score, satisfaction_score, wellbeing_score,
    culture_score, leadership_score, development_score,
    work_life_balance_score, recognition_score, overall_score,
    key_findings, action_items, employee_feedback
)
SELECT 
    survey_id,
    TO_DATE(survey_date, 'YYYY-MM-DD'),
    department,
    response_rate,
    engagement_score,
    satisfaction_score,
    wellbeing_score,
    culture_score,
    leadership_score,
    development_score,
    work_life_balance_score,
    recognition_score,
    overall_score,
    key_findings,
    action_items,
    employee_feedback
FROM EXTERNAL (
    (survey_id CHAR(20),
     survey_date CHAR(10),
     department CHAR(50),
     response_rate CHAR(10),
     engagement_score CHAR(10),
     satisfaction_score CHAR(10),
     wellbeing_score CHAR(10),
     culture_score CHAR(10),
     leadership_score CHAR(10),
     development_score CHAR(10),
     work_life_balance_score CHAR(10),
     recognition_score CHAR(10),
     overall_score CHAR(10),
     key_findings CHAR(2000),
     action_items CHAR(2000),
     employee_feedback CHAR(2000))
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET AL32UTF8
        BADFILE data_dir:'pulse_surveys_bad.log'
        LOGFILE data_dir:'pulse_surveys_load.log'
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('pulse_surveys.csv')
    REJECT LIMIT UNLIMITED
);

-- Load data into employees
INSERT INTO employees (
    first_name, last_name, email, department,
    position, hire_date, status
)
SELECT 
    first_name,
    last_name,
    email,
    department,
    position,
    TO_DATE(hire_date, 'YYYY-MM-DD'),
    status
FROM EXTERNAL (
    (first_name CHAR(100),
     last_name CHAR(100),
     email CHAR(200),
     department CHAR(100),
     position CHAR(100),
     hire_date CHAR(10),
     status CHAR(50))
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET AL32UTF8
        BADFILE data_dir:'employees_bad.log'
        LOGFILE data_dir:'employees_load.log'
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('employees.csv')
    REJECT LIMIT UNLIMITED
);

-- Load data into performance_reviews
INSERT INTO performance_reviews (
    employee_id, review_date, reviewer_id,
    overall_rating, comments
)
SELECT 
    TO_NUMBER(employee_id),
    TO_DATE(review_date, 'YYYY-MM-DD'),
    TO_NUMBER(reviewer_id),
    TO_NUMBER(overall_rating),
    comments
FROM EXTERNAL (
    (employee_id CHAR(10),
     review_date CHAR(10),
     reviewer_id CHAR(10),
     overall_rating CHAR(10),
     comments CHAR(2000))
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET AL32UTF8
        BADFILE data_dir:'performance_reviews_bad.log'
        LOGFILE data_dir:'performance_reviews_load.log'
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
    )
    LOCATION ('performance_reviews.csv')
    REJECT LIMIT UNLIMITED
);

-- Commit the changes
COMMIT;

-- Exit SQL*Plus
EXIT;

-- Create table for pulse surveys
CREATE TABLE pulse_surveys (
    survey_id VARCHAR(20) PRIMARY KEY,
    survey_date DATE NOT NULL,
    department VARCHAR(50) NOT NULL,
    response_rate DECIMAL(5,4) CHECK (response_rate BETWEEN 0 AND 1),
    engagement_score DECIMAL(5,4) CHECK (engagement_score BETWEEN 0 AND 1),
    satisfaction_score DECIMAL(5,4) CHECK (satisfaction_score BETWEEN 0 AND 1),
    wellbeing_score DECIMAL(5,4) CHECK (wellbeing_score BETWEEN 0 AND 1),
    culture_score DECIMAL(5,4) CHECK (culture_score BETWEEN 0 AND 1),
    leadership_score DECIMAL(5,4) CHECK (leadership_score BETWEEN 0 AND 1),
    development_score DECIMAL(5,4) CHECK (development_score BETWEEN 0 AND 1),
    work_life_balance_score DECIMAL(5,4) CHECK (work_life_balance_score BETWEEN 0 AND 1),
    recognition_score DECIMAL(5,4) CHECK (recognition_score BETWEEN 0 AND 1),
    overall_score DECIMAL(5,4) CHECK (overall_score BETWEEN 0 AND 1),
    key_findings TEXT,
    action_items TEXT,
    employee_feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for common queries
CREATE INDEX idx_pulse_surveys_date ON pulse_surveys(survey_date);
CREATE INDEX idx_pulse_surveys_dept ON pulse_surveys(department);

-- Create trigger for timestamp updates
CREATE TRIGGER pulse_surveys_update_trigger
ON pulse_surveys
AFTER UPDATE AS
BEGIN
    UPDATE pulse_surveys 
    SET updated_at = CURRENT_TIMESTAMP
    WHERE survey_id IN (SELECT DISTINCT survey_id FROM inserted);
END; 