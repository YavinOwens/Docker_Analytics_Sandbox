-- Trigger to update leave allowance timestamps
CREATE OR REPLACE TRIGGER trg_update_leave_allowance_timestamp
BEFORE UPDATE ON leave_allowances
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Trigger to validate leave taken
CREATE OR REPLACE TRIGGER trg_validate_leave_taken
BEFORE UPDATE OF leave_taken ON leave_allowances
FOR EACH ROW
BEGIN
    -- Check if leave taken exceeds total allowance
    IF :NEW.leave_taken > (:NEW.total_annual_leave + :NEW.additional_leave) THEN
        RAISE_APPLICATION_ERROR(-20004, 'Leave taken cannot exceed total allowance');
    END IF;
    
    -- Check if leave taken is negative
    IF :NEW.leave_taken < 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Leave taken cannot be negative');
    END IF;
END;
/

-- Trigger to validate survey scores
CREATE OR REPLACE TRIGGER trg_validate_survey_scores
BEFORE INSERT OR UPDATE ON pulse_surveys
FOR EACH ROW
BEGIN
    -- Validate all scores are between 1 and 5
    IF :NEW.engagement_score NOT BETWEEN 1 AND 5 OR
       :NEW.satisfaction_score NOT BETWEEN 1 AND 5 OR
       :NEW.work_life_balance_score NOT BETWEEN 1 AND 5 OR
       :NEW.career_growth_score NOT BETWEEN 1 AND 5 OR
       :NEW.management_support_score NOT BETWEEN 1 AND 5 THEN
        RAISE_APPLICATION_ERROR(-20006, 'All survey scores must be between 1 and 5');
    END IF;
END;
/

-- Trigger to prevent survey date in future
CREATE OR REPLACE TRIGGER trg_validate_survey_date
BEFORE INSERT OR UPDATE ON pulse_surveys
FOR EACH ROW
BEGIN
    IF :NEW.survey_date > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20007, 'Survey date cannot be in the future');
    END IF;
END;
/

-- Trigger to maintain leave history
CREATE OR REPLACE TRIGGER trg_maintain_leave_history
AFTER UPDATE OF leave_taken ON leave_allowances
FOR EACH ROW
BEGIN
    -- Insert into leave history if leave taken has changed
    IF :OLD.leave_taken != :NEW.leave_taken THEN
        INSERT INTO leave_history (
            employee_id,
            year,
            leave_taken,
            change_date,
            change_type
        ) VALUES (
            :NEW.employee_id,
            :NEW.year,
            :NEW.leave_taken,
            SYSDATE,
            CASE 
                WHEN :NEW.leave_taken > :OLD.leave_taken THEN 'TAKEN'
                ELSE 'CANCELLED'
            END
        );
    END IF;
END;
/

-- Trigger to enforce minimum survey participation
CREATE OR REPLACE TRIGGER trg_enforce_minimum_participation
AFTER INSERT ON pulse_surveys
FOR EACH ROW
DECLARE
    v_participation_rate NUMBER;
BEGIN
    -- Calculate participation rate
    SELECT (COUNT(*) / (SELECT COUNT(*) FROM employees WHERE department_id = :NEW.department_id)) * 100
    INTO v_participation_rate
    FROM pulse_surveys
    WHERE department_id = :NEW.department_id
    AND survey_date = :NEW.survey_date;
    
    -- If participation rate is too low, log warning
    IF v_participation_rate < 30 THEN
        INSERT INTO survey_warnings (
            department_id,
            survey_date,
            warning_message,
            warning_date
        ) VALUES (
            :NEW.department_id,
            :NEW.survey_date,
            'Low survey participation rate: ' || v_participation_rate || '%',
            SYSDATE
        );
    END IF;
END;
/ 