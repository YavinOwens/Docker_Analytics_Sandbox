-- Verify procedures
SELECT object_name, object_type, status
FROM user_objects
WHERE object_type IN ('PROCEDURE', 'FUNCTION', 'TRIGGER')
ORDER BY object_type, object_name;

-- Verify procedure source code
SELECT name, type, line, text
FROM user_source
WHERE type IN ('PROCEDURE', 'FUNCTION', 'TRIGGER')
ORDER BY name, type, line;

-- Verify procedure grants
SELECT table_name, privilege, grantee
FROM user_tab_privs
WHERE table_name IN (
    'LEAVE_ALLOWANCES',
    'PULSE_SURVEYS',
    'LEAVE_HISTORY',
    'SURVEY_WARNINGS'
);

-- Test procedure execution
DECLARE
    v_trend_data SYS_REFCURSOR;
BEGIN
    -- Test initialize_leave_allowances
    initialize_leave_allowances(EXTRACT(YEAR FROM SYSDATE));
    
    -- Test calculate_department_survey_trends
    calculate_department_survey_trends(
        1, -- department_id
        SYSDATE - 30, -- start_date
        SYSDATE, -- end_date
        v_trend_data
    );
    
    -- Test other functions
    DBMS_OUTPUT.PUT_LINE('Statutory leave for 5 years service: ' || 
        calculate_statutory_leave(5));
    
    DBMS_OUTPUT.PUT_LINE('Department survey participation: ' || 
        get_department_survey_participation(1, SYSDATE));
        
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/ 