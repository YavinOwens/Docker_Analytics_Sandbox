-- Function to calculate statutory leave entitlement
CREATE OR REPLACE FUNCTION calculate_statutory_leave(
    p_years_of_service NUMBER
) RETURN NUMBER IS
    v_base_leave NUMBER := 28; -- Statutory minimum
    v_additional_leave NUMBER := 0;
BEGIN
    -- Add additional days based on years of service
    IF p_years_of_service >= 5 THEN
        v_additional_leave := v_additional_leave + 1;
    END IF;
    IF p_years_of_service >= 10 THEN
        v_additional_leave := v_additional_leave + 1;
    END IF;
    IF p_years_of_service >= 15 THEN
        v_additional_leave := v_additional_leave + 1;
    END IF;
    
    RETURN v_base_leave + v_additional_leave;
END;
/

-- Function to calculate remaining leave balance
CREATE OR REPLACE FUNCTION calculate_leave_balance(
    p_employee_id NUMBER,
    p_year NUMBER
) RETURN NUMBER IS
    v_balance NUMBER;
BEGIN
    SELECT total_annual_leave + additional_leave - leave_taken
    INTO v_balance
    FROM leave_allowances
    WHERE employee_id = p_employee_id
    AND year = p_year;
    
    RETURN v_balance;
END;
/

-- Function to get department survey average
CREATE OR REPLACE FUNCTION get_department_survey_average(
    p_department_id NUMBER,
    p_survey_date DATE,
    p_metric VARCHAR2
) RETURN NUMBER IS
    v_average NUMBER;
BEGIN
    CASE p_metric
        WHEN 'engagement' THEN
            SELECT AVG(engagement_score)
            INTO v_average
            FROM pulse_surveys
            WHERE department_id = p_department_id
            AND survey_date = p_survey_date;
            
        WHEN 'satisfaction' THEN
            SELECT AVG(satisfaction_score)
            INTO v_average
            FROM pulse_surveys
            WHERE department_id = p_department_id
            AND survey_date = p_survey_date;
            
        WHEN 'work_life_balance' THEN
            SELECT AVG(work_life_balance_score)
            INTO v_average
            FROM pulse_surveys
            WHERE department_id = p_department_id
            AND survey_date = p_survey_date;
            
        WHEN 'career_growth' THEN
            SELECT AVG(career_growth_score)
            INTO v_average
            FROM pulse_surveys
            WHERE department_id = p_department_id
            AND survey_date = p_survey_date;
            
        WHEN 'management_support' THEN
            SELECT AVG(management_support_score)
            INTO v_average
            FROM pulse_surveys
            WHERE department_id = p_department_id
            AND survey_date = p_survey_date;
            
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'Invalid metric specified');
    END CASE;
    
    RETURN ROUND(v_average, 2);
END;
/

-- Function to check if employee has sufficient leave
CREATE OR REPLACE FUNCTION has_sufficient_leave(
    p_employee_id NUMBER,
    p_year NUMBER,
    p_days_requested NUMBER
) RETURN BOOLEAN IS
    v_balance NUMBER;
BEGIN
    v_balance := calculate_leave_balance(p_employee_id, p_year);
    RETURN v_balance >= p_days_requested;
END;
/

-- Function to get department survey participation rate
CREATE OR REPLACE FUNCTION get_department_survey_participation(
    p_department_id NUMBER,
    p_survey_date DATE
) RETURN NUMBER IS
    v_participation_rate NUMBER;
    v_total_employees NUMBER;
    v_survey_responses NUMBER;
BEGIN
    -- Get total employees in department
    SELECT COUNT(*)
    INTO v_total_employees
    FROM employees
    WHERE department_id = p_department_id;
    
    -- Get number of survey responses
    SELECT COUNT(*)
    INTO v_survey_responses
    FROM pulse_surveys
    WHERE department_id = p_department_id
    AND survey_date = p_survey_date;
    
    -- Calculate participation rate
    v_participation_rate := (v_survey_responses / v_total_employees) * 100;
    
    RETURN ROUND(v_participation_rate, 2);
END;
/ 