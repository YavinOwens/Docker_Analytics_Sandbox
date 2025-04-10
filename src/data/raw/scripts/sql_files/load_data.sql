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
    quarter, year, quarter_number, water_quality_score,
    customer_service_score, leakage_reduction_score,
    water_efficiency_score, environmental_impact_score,
    operational_efficiency_score, overall_performance_score,
    performance_rating, regulatory_compliance,
    financial_incentives_earned
)
SELECT 
    quarter,
    TO_NUMBER(year),
    TO_NUMBER(quarter_number),
    TO_NUMBER(water_quality_score),
    TO_NUMBER(customer_service_score),
    TO_NUMBER(leakage_reduction_score),
    TO_NUMBER(water_efficiency_score),
    TO_NUMBER(environmental_impact_score),
    TO_NUMBER(operational_efficiency_score),
    TO_NUMBER(overall_performance_score),
    performance_rating,
    regulatory_compliance,
    TO_NUMBER(REPLACE(REPLACE(financial_incentives_earned, '$', ''), ',', ''))
FROM EXTERNAL (
    (quarter CHAR(10),
     year CHAR(4),
     quarter_number CHAR(1),
     water_quality_score CHAR(10),
     customer_service_score CHAR(10),
     leakage_reduction_score CHAR(10),
     water_efficiency_score CHAR(10),
     environmental_impact_score CHAR(10),
     operational_efficiency_score CHAR(10),
     overall_performance_score CHAR(10),
     performance_rating CHAR(50),
     key_achievements CHAR(1000),
     areas_for_improvement CHAR(1000),
     regulatory_compliance CHAR(50),
     financial_incentives_earned CHAR(20))
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
    project_id, project_name, project_type,
    start_date, planned_end_date, actual_end_date,
    base_budget, contingency_budget, total_budget,
    actual_cost, progress_percentage, status,
    priority, risk_level
)
SELECT 
    project_id,
    project_name,
    project_type,
    TO_DATE(start_date, 'YYYY-MM-DD'),
    TO_DATE(planned_end_date, 'YYYY-MM-DD'),
    TO_DATE(actual_end_date, 'YYYY-MM-DD'),
    TO_NUMBER(REPLACE(REPLACE(base_budget, '$', ''), ',', '')),
    TO_NUMBER(REPLACE(REPLACE(contingency_budget, '$', ''), ',', '')),
    TO_NUMBER(REPLACE(REPLACE(total_budget, '$', ''), ',', '')),
    TO_NUMBER(REPLACE(REPLACE(actual_cost, '$', ''), ',', '')),
    TO_NUMBER(REPLACE(progress_percentage, '%', '')),
    status,
    priority,
    risk_level
FROM EXTERNAL (
    (project_id CHAR(20),
     project_name CHAR(200),
     project_type CHAR(100),
     start_date CHAR(10),
     planned_end_date CHAR(10),
     actual_end_date CHAR(10),
     base_budget CHAR(20),
     contingency_budget CHAR(20),
     total_budget CHAR(20),
     actual_cost CHAR(20),
     progress_percentage CHAR(10),
     status CHAR(50),
     priority CHAR(50),
     risk_level CHAR(50),
     benefits_realized CHAR(1000),
     key_milestones CHAR(1000),
     stakeholders CHAR(1000))
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
    survey_type, respondent_id, response_date,
    score, comments
)
SELECT 
    survey_type,
    respondent_id,
    TO_DATE(response_date, 'YYYY-MM-DD'),
    TO_NUMBER(score),
    comments
FROM EXTERNAL (
    (survey_type CHAR(100),
     respondent_id CHAR(100),
     response_date CHAR(10),
     score CHAR(10),
     comments CHAR(1000))
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