-- Create the table
CREATE TABLE pulse_surveys (
    survey_id VARCHAR2(20) PRIMARY KEY,
    survey_date DATE,
    department VARCHAR2(50),
    response_rate NUMBER(5,4),
    engagement_score NUMBER(5,4),
    satisfaction_score NUMBER(5,4),
    wellbeing_score NUMBER(5,4),
    culture_score NUMBER(5,4),
    leadership_score NUMBER(5,4),
    development_score NUMBER(5,4),
    work_life_balance_score NUMBER(5,4),
    recognition_score NUMBER(5,4),
    overall_score NUMBER(5,4),
    key_findings CLOB,
    action_items CLOB,
    employee_feedback CLOB,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Create a directory object for the CSV file
CREATE OR REPLACE DIRECTORY data_dir AS '/opt/oracle/data';

-- Create external table
CREATE TABLE pulse_surveys_ext (
    survey_id VARCHAR2(20),
    survey_date DATE,
    department VARCHAR2(50),
    response_rate NUMBER(5,4),
    engagement_score NUMBER(5,4),
    satisfaction_score NUMBER(5,4),
    wellbeing_score NUMBER(5,4),
    culture_score NUMBER(5,4),
    leadership_score NUMBER(5,4),
    development_score NUMBER(5,4),
    work_life_balance_score NUMBER(5,4),
    recognition_score NUMBER(5,4),
    overall_score NUMBER(5,4),
    key_findings VARCHAR2(4000),
    action_items VARCHAR2(4000),
    employee_feedback VARCHAR2(4000)
)
ORGANIZATION EXTERNAL (
    TYPE ORACLE_LOADER
    DEFAULT DIRECTORY data_dir
    ACCESS PARAMETERS (
        RECORDS DELIMITED BY NEWLINE
        CHARACTERSET AL32UTF8
        BADFILE 'pulse_surveys_bad.log'
        LOGFILE 'pulse_surveys_load.log'
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        MISSING FIELD VALUES ARE NULL
        REJECT ROWS WITH ALL NULL FIELDS
    )
    LOCATION ('pulse_surveys.csv')
);

-- Insert data from external table to main table
INSERT INTO pulse_surveys
SELECT * FROM pulse_surveys_ext;

-- Drop external table
DROP TABLE pulse_surveys_ext;

-- Drop directory
DROP DIRECTORY data_dir; 