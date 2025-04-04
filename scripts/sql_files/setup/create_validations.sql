-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format
SET LINESIZE 1000
SET PAGESIZE 1000

-- Drop existing objects
DROP VIEW v_data_quality_metrics;
DROP PROCEDURE check_data_quality;

-- Drop existing constraints
ALTER TABLE water_utility_assets DROP CONSTRAINT chk_asset_status;
ALTER TABLE water_utility_assets DROP CONSTRAINT chk_asset_dates;

ALTER TABLE water_utilities_work_orders DROP CONSTRAINT chk_work_order_status;
ALTER TABLE water_utilities_work_orders DROP CONSTRAINT chk_work_order_priority;
ALTER TABLE water_utilities_work_orders DROP CONSTRAINT chk_work_order_dates;

ALTER TABLE ofwat_results DROP CONSTRAINT chk_ofwat_status;
ALTER TABLE ofwat_results DROP CONSTRAINT chk_ofwat_values;

ALTER TABLE capex_projects DROP CONSTRAINT chk_capex_status;
ALTER TABLE capex_projects DROP CONSTRAINT chk_capex_amounts;
ALTER TABLE capex_projects DROP CONSTRAINT chk_capex_dates;

ALTER TABLE pulse_surveys DROP CONSTRAINT chk_survey_score;
ALTER TABLE pulse_surveys DROP CONSTRAINT chk_survey_type;

ALTER TABLE employees DROP CONSTRAINT chk_employee_status;
ALTER TABLE employees DROP CONSTRAINT chk_employee_email;
ALTER TABLE employees DROP CONSTRAINT chk_employee_department;

ALTER TABLE performance_reviews DROP CONSTRAINT chk_review_rating;

-- Add check constraints for data validation
ALTER TABLE water_utility_assets ADD CONSTRAINT chk_asset_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DECOMMISSIONED'));
ALTER TABLE water_utility_assets ADD CONSTRAINT chk_asset_dates CHECK (installation_date <= last_maintenance_date AND last_maintenance_date <= next_maintenance_date);

ALTER TABLE water_utilities_work_orders ADD CONSTRAINT chk_work_order_status CHECK (status IN ('OPEN', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'));
ALTER TABLE water_utilities_work_orders ADD CONSTRAINT chk_work_order_priority CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL'));
ALTER TABLE water_utilities_work_orders ADD CONSTRAINT chk_work_order_dates CHECK (created_date <= completed_date);

ALTER TABLE ofwat_results ADD CONSTRAINT chk_ofwat_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED'));
ALTER TABLE ofwat_results ADD CONSTRAINT chk_ofwat_values CHECK (target_value >= 0 AND actual_value >= 0);

ALTER TABLE capex_projects ADD CONSTRAINT chk_capex_status CHECK (status IN ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'));
ALTER TABLE capex_projects ADD CONSTRAINT chk_capex_amounts CHECK (budget_amount >= 0 AND spent_amount >= 0 AND spent_amount <= budget_amount);
ALTER TABLE capex_projects ADD CONSTRAINT chk_capex_dates CHECK (start_date <= end_date);

ALTER TABLE pulse_surveys ADD CONSTRAINT chk_survey_score CHECK (score >= 0 AND score <= 5);
ALTER TABLE pulse_surveys ADD CONSTRAINT chk_survey_type CHECK (survey_type IN ('CUSTOMER_SATISFACTION', 'EMPLOYEE_ENGAGEMENT', 'SERVICE_QUALITY'));

ALTER TABLE employees ADD CONSTRAINT chk_employee_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'ON_LEAVE', 'TERMINATED'));
ALTER TABLE employees ADD CONSTRAINT chk_employee_email CHECK (REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'));
ALTER TABLE employees ADD CONSTRAINT chk_employee_department CHECK (department IN ('IT', 'OPERATIONS', 'FINANCE', 'HR', 'CUSTOMER_SERVICE', 'MAINTENANCE'));

ALTER TABLE performance_reviews ADD CONSTRAINT chk_review_rating CHECK (overall_rating >= 1 AND overall_rating <= 5);

-- Create triggers for business logic validation
CREATE OR REPLACE TRIGGER trg_work_order_asset_status
BEFORE INSERT OR UPDATE ON water_utilities_work_orders
FOR EACH ROW
DECLARE
    v_asset_status VARCHAR2(50);
BEGIN
    SELECT status INTO v_asset_status
    FROM water_utility_assets
    WHERE asset_id = :NEW.asset_id;
    
    IF v_asset_status = 'INACTIVE' OR v_asset_status = 'DECOMMISSIONED' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot create/update work order for inactive or decommissioned asset');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_performance_review_employee_status
BEFORE INSERT OR UPDATE ON performance_reviews
FOR EACH ROW
DECLARE
    v_employee_status VARCHAR2(50);
BEGIN
    SELECT status INTO v_employee_status
    FROM employees
    WHERE employee_id = :NEW.employee_id;
    
    IF v_employee_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Performance review can only be created/updated for active employees');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_capex_budget_change
BEFORE UPDATE OF budget_amount ON capex_projects
FOR EACH ROW
BEGIN
    IF :NEW.budget_amount < :OLD.spent_amount THEN
        RAISE_APPLICATION_ERROR(-20004, 'Cannot reduce budget below spent amount');
    END IF;
END;
/

-- Create functions for validation
CREATE OR REPLACE FUNCTION validate_email(p_email VARCHAR2)
RETURN BOOLEAN IS
BEGIN
    RETURN REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
END;
/

CREATE OR REPLACE FUNCTION validate_date_range(p_start_date DATE, p_end_date DATE)
RETURN BOOLEAN IS
BEGIN
    RETURN p_start_date <= p_end_date;
END;
/

-- Create view for monitoring data quality
CREATE OR REPLACE VIEW v_data_quality_metrics AS
SELECT 
    'water_utility_assets' as table_name,
    COUNT(*) as total_rows,
    COUNT(CASE WHEN status IS NULL THEN 1 END) as null_status,
    COUNT(CASE WHEN installation_date IS NULL THEN 1 END) as null_field1,
    COUNT(CASE WHEN last_maintenance_date IS NULL THEN 1 END) as null_field2
FROM water_utility_assets
UNION ALL
SELECT 
    'water_utilities_work_orders',
    COUNT(*),
    COUNT(CASE WHEN status IS NULL THEN 1 END),
    COUNT(CASE WHEN created_date IS NULL THEN 1 END),
    COUNT(CASE WHEN completed_date IS NULL THEN 1 END)
FROM water_utilities_work_orders
UNION ALL
SELECT 
    'ofwat_results',
    COUNT(*),
    COUNT(CASE WHEN status IS NULL THEN 1 END),
    COUNT(CASE WHEN target_value IS NULL THEN 1 END),
    COUNT(CASE WHEN actual_value IS NULL THEN 1 END)
FROM ofwat_results
UNION ALL
SELECT 
    'capex_projects',
    COUNT(*),
    COUNT(CASE WHEN status IS NULL THEN 1 END),
    COUNT(CASE WHEN budget_amount IS NULL THEN 1 END),
    COUNT(CASE WHEN spent_amount IS NULL THEN 1 END)
FROM capex_projects
UNION ALL
SELECT 
    'pulse_surveys',
    COUNT(*),
    COUNT(CASE WHEN survey_type IS NULL THEN 1 END),
    COUNT(CASE WHEN score IS NULL THEN 1 END),
    COUNT(CASE WHEN response_date IS NULL THEN 1 END)
FROM pulse_surveys
UNION ALL
SELECT 
    'employees',
    COUNT(*),
    COUNT(CASE WHEN status IS NULL THEN 1 END),
    COUNT(CASE WHEN email IS NULL THEN 1 END),
    COUNT(CASE WHEN department IS NULL THEN 1 END)
FROM employees
UNION ALL
SELECT 
    'performance_reviews',
    COUNT(*),
    COUNT(CASE WHEN overall_rating IS NULL THEN 1 END),
    COUNT(CASE WHEN review_date IS NULL THEN 1 END),
    COUNT(CASE WHEN reviewer_id IS NULL THEN 1 END)
FROM performance_reviews;

-- Create procedure to check data quality
CREATE OR REPLACE PROCEDURE check_data_quality IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Data Quality Report');
    DBMS_OUTPUT.PUT_LINE('==================');
    
    FOR r IN (SELECT * FROM v_data_quality_metrics) LOOP
        DBMS_OUTPUT.PUT_LINE(CHR(10) || 'Table: ' || r.table_name);
        DBMS_OUTPUT.PUT_LINE('Total Rows: ' || r.total_rows);
        DBMS_OUTPUT.PUT_LINE('Null Status: ' || r.null_status || 
                           ' (' || ROUND(r.null_status / NULLIF(r.total_rows, 0) * 100, 2) || '%)');
        DBMS_OUTPUT.PUT_LINE('Null Field 1: ' || r.null_field1 || 
                           ' (' || ROUND(r.null_field1 / NULLIF(r.total_rows, 0) * 100, 2) || '%)');
        DBMS_OUTPUT.PUT_LINE('Null Field 2: ' || r.null_field2 || 
                           ' (' || ROUND(r.null_field2 / NULLIF(r.total_rows, 0) * 100, 2) || '%)');
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in check_data_quality: ' || SQLERRM);
        RAISE;
END;
/

-- Grant execute permission
GRANT EXECUTE ON check_data_quality TO PUBLIC;

-- Commit changes
COMMIT;

-- Test the data quality check
SET SERVEROUTPUT ON
EXEC check_data_quality;

-- Exit SQL*Plus
EXIT; 