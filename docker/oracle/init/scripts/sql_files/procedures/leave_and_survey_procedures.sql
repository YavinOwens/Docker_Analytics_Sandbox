-- Procedure to initialize leave allowances for new year
CREATE OR REPLACE PROCEDURE initialize_leave_allowances(
    p_year NUMBER
) IS
BEGIN
    INSERT INTO leave_allowances (
        employee_id,
        year,
        total_annual_leave,
        bank_holidays
    )
    SELECT 
        e.employee_id,
        p_year,
        calculate_statutory_leave(
            EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM e.hire_date)
        ),
        8 -- Default bank holidays
    FROM employees e
    WHERE NOT EXISTS (
        SELECT 1 
        FROM leave_allowances la 
        WHERE la.employee_id = e.employee_id 
        AND la.year = p_year
    );
END;
/

-- Procedure to update leave taken
CREATE OR REPLACE PROCEDURE update_leave_taken(
    p_employee_id NUMBER,
    p_year NUMBER,
    p_days_taken NUMBER
) IS
    v_total_leave NUMBER;
    v_current_leave_taken NUMBER;
BEGIN
    -- Get current leave allowance
    SELECT total_annual_leave + additional_leave, leave_taken
    INTO v_total_leave, v_current_leave_taken
    FROM leave_allowances
    WHERE employee_id = p_employee_id
    AND year = p_year;

    -- Validate leave request
    IF v_current_leave_taken + p_days_taken > v_total_leave THEN
        RAISE_APPLICATION_ERROR(-20001, 'Insufficient leave balance');
    END IF;

    -- Update leave taken
    UPDATE leave_allowances
    SET leave_taken = leave_taken + p_days_taken
    WHERE employee_id = p_employee_id
    AND year = p_year;

    COMMIT;
END;
/

-- Procedure to record pulse survey submission
CREATE OR REPLACE PROCEDURE record_pulse_survey(
    p_department_id NUMBER,
    p_survey_date DATE,
    p_engagement_score NUMBER,
    p_satisfaction_score NUMBER,
    p_work_life_balance_score NUMBER,
    p_career_growth_score NUMBER,
    p_management_support_score NUMBER,
    p_comments CLOB
) IS
BEGIN
    -- Validate scores
    IF p_engagement_score NOT BETWEEN 1 AND 5 OR
       p_satisfaction_score NOT BETWEEN 1 AND 5 OR
       p_work_life_balance_score NOT BETWEEN 1 AND 5 OR
       p_career_growth_score NOT BETWEEN 1 AND 5 OR
       p_management_support_score NOT BETWEEN 1 AND 5 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Survey scores must be between 1 and 5');
    END IF;

    -- Insert survey record
    INSERT INTO pulse_surveys (
        department_id,
        survey_date,
        engagement_score,
        satisfaction_score,
        work_life_balance_score,
        career_growth_score,
        management_support_score,
        comments
    ) VALUES (
        p_department_id,
        p_survey_date,
        p_engagement_score,
        p_satisfaction_score,
        p_work_life_balance_score,
        p_career_growth_score,
        p_management_support_score,
        p_comments
    );

    COMMIT;
END;
/

-- Procedure to calculate department survey trends
CREATE OR REPLACE PROCEDURE calculate_department_survey_trends(
    p_department_id NUMBER,
    p_start_date DATE,
    p_end_date DATE,
    p_trend_data OUT SYS_REFCURSOR
) IS
BEGIN
    OPEN p_trend_data FOR
    SELECT 
        survey_date,
        ROUND(AVG(engagement_score), 2) as avg_engagement,
        ROUND(AVG(satisfaction_score), 2) as avg_satisfaction,
        ROUND(AVG(work_life_balance_score), 2) as avg_work_life_balance,
        ROUND(AVG(career_growth_score), 2) as avg_career_growth,
        ROUND(AVG(management_support_score), 2) as avg_management_support,
        COUNT(*) as response_count
    FROM pulse_surveys
    WHERE department_id = p_department_id
    AND survey_date BETWEEN p_start_date AND p_end_date
    GROUP BY survey_date
    ORDER BY survey_date;
END;
/ 