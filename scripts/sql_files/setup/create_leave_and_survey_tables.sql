-- Create leave allowance table
CREATE TABLE leave_allowances (
    allowance_id NUMBER GENERATED ALWAYS AS IDENTITY,
    employee_id NUMBER NOT NULL,
    year NUMBER NOT NULL,
    total_annual_leave NUMBER NOT NULL,
    bank_holidays NUMBER NOT NULL,
    additional_leave NUMBER DEFAULT 0,
    leave_taken NUMBER DEFAULT 0,
    leave_remaining NUMBER GENERATED ALWAYS AS (total_annual_leave + additional_leave - leave_taken) VIRTUAL,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_leave_allowances PRIMARY KEY (allowance_id),
    CONSTRAINT fk_leave_allowances_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT chk_leave_days CHECK (total_annual_leave >= 28 AND total_annual_leave <= 40),
    CONSTRAINT chk_bank_holidays CHECK (bank_holidays >= 8 AND bank_holidays <= 10),
    CONSTRAINT chk_leave_taken CHECK (leave_taken >= 0 AND leave_taken <= (total_annual_leave + additional_leave))
);

-- Create pulse survey table with anonymization
CREATE TABLE pulse_surveys (
    survey_id NUMBER GENERATED ALWAYS AS IDENTITY,
    department_id NUMBER NOT NULL,
    survey_date DATE NOT NULL,
    engagement_score NUMBER NOT NULL,
    satisfaction_score NUMBER NOT NULL,
    work_life_balance_score NUMBER NOT NULL,
    career_growth_score NUMBER NOT NULL,
    management_support_score NUMBER NOT NULL,
    comments CLOB,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT pk_pulse_surveys PRIMARY KEY (survey_id),
    CONSTRAINT fk_pulse_surveys_department FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT chk_survey_scores CHECK (
        engagement_score BETWEEN 1 AND 5 AND
        satisfaction_score BETWEEN 1 AND 5 AND
        work_life_balance_score BETWEEN 1 AND 5 AND
        career_growth_score BETWEEN 1 AND 5 AND
        management_support_score BETWEEN 1 AND 5
    )
);

-- Create view for leave balance calculations
CREATE OR REPLACE VIEW leave_balance_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    d.department_name,
    la.year,
    la.total_annual_leave,
    la.bank_holidays,
    la.additional_leave,
    la.leave_taken,
    la.leave_remaining,
    CASE 
        WHEN la.leave_remaining < 5 THEN 'Low Balance'
        WHEN la.leave_remaining < 10 THEN 'Medium Balance'
        ELSE 'Good Balance'
    END as balance_status
FROM employees e
JOIN departments d ON e.department_id = d.department_id
JOIN leave_allowances la ON e.employee_id = la.employee_id;

-- Create view for department pulse survey analytics
CREATE OR REPLACE VIEW pulse_survey_analytics AS
SELECT 
    d.department_id,
    d.department_name,
    ps.survey_date,
    ROUND(AVG(ps.engagement_score), 2) as avg_engagement,
    ROUND(AVG(ps.satisfaction_score), 2) as avg_satisfaction,
    ROUND(AVG(ps.work_life_balance_score), 2) as avg_work_life_balance,
    ROUND(AVG(ps.career_growth_score), 2) as avg_career_growth,
    ROUND(AVG(ps.management_support_score), 2) as avg_management_support,
    COUNT(*) as response_count
FROM departments d
JOIN pulse_surveys ps ON d.department_id = ps.department_id
GROUP BY d.department_id, d.department_name, ps.survey_date;

-- Create trigger to update leave allowance timestamps
CREATE OR REPLACE TRIGGER trg_update_leave_allowance_timestamp
BEFORE UPDATE ON leave_allowances
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Create function to calculate statutory leave entitlement
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

-- Create procedure to initialize leave allowances for new year
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