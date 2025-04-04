-- Drop the table if it exists
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE pulse_surveys';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

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