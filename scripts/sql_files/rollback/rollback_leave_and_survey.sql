-- Disable triggers first
ALTER TRIGGER trg_update_leave_allowance_timestamp DISABLE;
ALTER TRIGGER trg_validate_leave_taken DISABLE;
ALTER TRIGGER trg_validate_survey_scores DISABLE;
ALTER TRIGGER trg_validate_survey_date DISABLE;
ALTER TRIGGER trg_maintain_leave_history DISABLE;
ALTER TRIGGER trg_enforce_minimum_participation DISABLE;

-- Drop triggers
DROP TRIGGER trg_update_leave_allowance_timestamp;
DROP TRIGGER trg_validate_leave_taken;
DROP TRIGGER trg_validate_survey_scores;
DROP TRIGGER trg_validate_survey_date;
DROP TRIGGER trg_maintain_leave_history;
DROP TRIGGER trg_enforce_minimum_participation;

-- Drop functions
DROP FUNCTION calculate_statutory_leave;
DROP FUNCTION calculate_leave_balance;
DROP FUNCTION get_department_survey_average;
DROP FUNCTION has_sufficient_leave;
DROP FUNCTION get_department_survey_participation;

-- Drop procedures
DROP PROCEDURE initialize_leave_allowances;
DROP PROCEDURE update_leave_taken;
DROP PROCEDURE record_pulse_survey;
DROP PROCEDURE calculate_department_survey_trends;

-- Drop views
DROP VIEW leave_balance_view;
DROP VIEW pulse_survey_analytics;

-- Drop tables
DROP TABLE survey_warnings CASCADE CONSTRAINTS;
DROP TABLE leave_history CASCADE CONSTRAINTS;
DROP TABLE pulse_surveys CASCADE CONSTRAINTS;
DROP TABLE leave_allowances CASCADE CONSTRAINTS;

-- Revoke privileges
REVOKE EXECUTE ON leave_and_survey_procedures FROM app_user;
REVOKE EXECUTE ON leave_and_survey_functions FROM app_user;
REVOKE EXECUTE ON leave_and_survey_triggers FROM app_user;

REVOKE SELECT, INSERT, UPDATE ON leave_allowances FROM app_user;
REVOKE SELECT, INSERT ON pulse_surveys FROM app_user;
REVOKE SELECT, INSERT ON leave_history FROM app_user;
REVOKE SELECT, INSERT ON survey_warnings FROM app_user;

-- Commit changes
COMMIT;

-- Verify objects are dropped
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'TRIGGER', 'VIEW', 'TABLE')
AND object_name IN (
    'LEAVE_ALLOWANCES',
    'PULSE_SURVEYS',
    'LEAVE_HISTORY',
    'SURVEY_WARNINGS',
    'LEAVE_BALANCE_VIEW',
    'PULSE_SURVEY_ANALYTICS',
    'CALCULATE_STATUTORY_LEAVE',
    'CALCULATE_LEAVE_BALANCE',
    'GET_DEPARTMENT_SURVEY_AVERAGE',
    'HAS_SUFFICIENT_LEAVE',
    'GET_DEPARTMENT_SURVEY_PARTICIPATION',
    'INITIALIZE_LEAVE_ALLOWANCES',
    'UPDATE_LEAVE_TAKEN',
    'RECORD_PULSE_SURVEY',
    'CALCULATE_DEPARTMENT_SURVEY_TRENDS',
    'TRG_UPDATE_LEAVE_ALLOWANCE_TIMESTAMP',
    'TRG_VALIDATE_LEAVE_TAKEN',
    'TRG_VALIDATE_SURVEY_SCORES',
    'TRG_VALIDATE_SURVEY_DATE',
    'TRG_MAINTAIN_LEAVE_HISTORY',
    'TRG_ENFORCE_MINIMUM_PARTICIPATION'
); 