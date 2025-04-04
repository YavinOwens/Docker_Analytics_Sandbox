-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Drop existing triggers if they exist
DROP TRIGGER TRG_WORK_ORDER_ASSET_STATUS;
DROP TRIGGER TRG_PERFORMANCE_REVIEW_EMPLOYEE_STATUS;

-- Create trigger to check asset status before creating/updating work orders
CREATE OR REPLACE TRIGGER TRG_WORK_ORDER_ASSET_STATUS
BEFORE INSERT OR UPDATE ON water_utilities_work_orders
FOR EACH ROW
DECLARE
    v_asset_status VARCHAR2(20);
BEGIN
    SELECT operational_status INTO v_asset_status
    FROM water_utilities_assets
    WHERE asset_id = :NEW.asset_id;
    
    IF v_asset_status = 'DECOMMISSIONED' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Cannot create or update work orders for decommissioned assets');
    END IF;
END;
/

-- Create trigger to check employee status before creating/updating performance reviews
CREATE OR REPLACE TRIGGER TRG_PERFORMANCE_REVIEW_EMPLOYEE_STATUS
BEFORE INSERT OR UPDATE ON performance_reviews
FOR EACH ROW
DECLARE
    v_employee_status VARCHAR2(20);
BEGIN
    SELECT employment_status INTO v_employee_status
    FROM employees
    WHERE employee_id = :NEW.employee_id;
    
    IF v_employee_status != 'Active' THEN
        RAISE_APPLICATION_ERROR(-20002, 'Performance reviews can only be created or updated for active employees');
    END IF;
END;
/

-- Commit the changes
COMMIT;

-- Exit SQL*Plus
EXIT; 