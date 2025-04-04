-- Grant necessary privileges
GRANT EXECUTE ON leave_and_survey_procedures TO app_user;
GRANT EXECUTE ON leave_and_survey_functions TO app_user;
GRANT EXECUTE ON leave_and_survey_triggers TO app_user;

-- Ensure tables exist and have proper privileges
CREATE TABLE IF NOT EXISTS leave_history (
    history_id NUMBER GENERATED ALWAYS AS IDENTITY,
    employee_id NUMBER NOT NULL,
    year NUMBER NOT NULL,
    leave_taken NUMBER NOT NULL,
    change_date TIMESTAMP NOT NULL,
    change_type VARCHAR2(10) NOT NULL,
    CONSTRAINT pk_leave_history PRIMARY KEY (history_id),
    CONSTRAINT fk_leave_history_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS survey_warnings (
    warning_id NUMBER GENERATED ALWAYS AS IDENTITY,
    department_id NUMBER NOT NULL,
    survey_date DATE NOT NULL,
    warning_message VARCHAR2(500) NOT NULL,
    warning_date TIMESTAMP NOT NULL,
    CONSTRAINT pk_survey_warnings PRIMARY KEY (warning_id),
    CONSTRAINT fk_survey_warnings_department FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- Grant table privileges
GRANT SELECT, INSERT, UPDATE ON leave_allowances TO app_user;
GRANT SELECT, INSERT ON pulse_surveys TO app_user;
GRANT SELECT, INSERT ON leave_history TO app_user;
GRANT SELECT, INSERT ON survey_warnings TO app_user;

-- Recompile all procedures, functions, and triggers
ALTER PROCEDURE initialize_leave_allowances COMPILE;
ALTER PROCEDURE update_leave_taken COMPILE;
ALTER PROCEDURE record_pulse_survey COMPILE;
ALTER PROCEDURE calculate_department_survey_trends COMPILE;

ALTER FUNCTION calculate_statutory_leave COMPILE;
ALTER FUNCTION calculate_leave_balance COMPILE;
ALTER FUNCTION get_department_survey_average COMPILE;
ALTER FUNCTION has_sufficient_leave COMPILE;
ALTER FUNCTION get_department_survey_participation COMPILE;

ALTER TRIGGER trg_update_leave_allowance_timestamp COMPILE;
ALTER TRIGGER trg_validate_leave_taken COMPILE;
ALTER TRIGGER trg_validate_survey_scores COMPILE;
ALTER TRIGGER trg_validate_survey_date COMPILE;
ALTER TRIGGER trg_maintain_leave_history COMPILE;
ALTER TRIGGER trg_enforce_minimum_participation COMPILE;

-- Verify compilation status
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'TRIGGER')
ORDER BY object_type, object_name;

-- Commit all changes
COMMIT;

-- Enable DBMS_OUTPUT for testing
SET SERVEROUTPUT ON;

-- Test procedure execution
DECLARE
    v_trend_data SYS_REFCURSOR;
BEGIN
    -- Test initialize_leave_allowances
    initialize_leave_allowances(EXTRACT(YEAR FROM SYSDATE));
    DBMS_OUTPUT.PUT_LINE('Successfully initialized leave allowances');
    
    -- Test calculate_department_survey_trends
    calculate_department_survey_trends(
        1, -- department_id
        SYSDATE - 30, -- start_date
        SYSDATE, -- end_date
        v_trend_data
    );
    DBMS_OUTPUT.PUT_LINE('Successfully calculated survey trends');
    
    -- Test other functions
    DBMS_OUTPUT.PUT_LINE('Statutory leave for 5 years service: ' || 
        calculate_statutory_leave(5));
    
    DBMS_OUTPUT.PUT_LINE('Department survey participation: ' || 
        get_department_survey_participation(1, SYSDATE));
        
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/ 