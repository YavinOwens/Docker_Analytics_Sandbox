WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Create views for common calculations
CREATE OR REPLACE VIEW v_device_performance_summary AS
SELECT 
    d.device_id,
    d.device_name,
    d.device_type,
    d.location,
    COUNT(p.performance_id) as total_readings,
    AVG(p.metric_value) as avg_metric_value,
    MIN(p.metric_value) as min_metric_value,
    MAX(p.metric_value) as max_metric_value,
    MAX(p.measurement_date) as last_reading_date
FROM industrial_iot_data d
LEFT JOIN industrial_performance p ON d.device_id = p.device_id
GROUP BY d.device_id, d.device_name, d.device_type, d.location;

-- Create view for maintenance efficiency
CREATE OR REPLACE VIEW v_maintenance_efficiency AS
SELECT 
    m.device_id,
    d.device_name,
    d.device_type,
    COUNT(m.maintenance_id) as total_maintenance_count,
    AVG(m.completed_date - m.scheduled_date) as avg_completion_delay,
    COUNT(CASE WHEN m.status = 'COMPLETED' THEN 1 END) as completed_maintenance_count,
    COUNT(CASE WHEN m.status = 'SCHEDULED' THEN 1 END) as pending_maintenance_count
FROM industrial_maintenance m
JOIN industrial_iot_data d ON m.device_id = d.device_id
GROUP BY m.device_id, d.device_name, d.device_type;

-- Create view for workforce utilization
CREATE OR REPLACE VIEW v_workforce_utilization AS
SELECT 
    e.department,
    COUNT(DISTINCT e.employee_id) as total_employees,
    COUNT(DISTINCT w.attendance_id) as total_attendance_records,
    COUNT(DISTINCT s.skill_id) as total_skills,
    COUNT(DISTINCT t.training_id) as total_training_records
FROM employees e
LEFT JOIN workforce_attendance w ON e.employee_id = w.employee_id
LEFT JOIN workforce_skills s ON e.employee_id = s.employee_id
LEFT JOIN workforce_training t ON e.employee_id = t.employee_id
GROUP BY e.department;

-- Create package for water quality calculations based on Ofwat guidelines
CREATE OR REPLACE PACKAGE water_quality_pkg AS
    -- Constants for Ofwat standards
    c_min_ph CONSTANT NUMBER := 6.5;
    c_max_ph CONSTANT NUMBER := 9.5;
    c_min_dissolved_oxygen CONSTANT NUMBER := 5.0; -- mg/L
    c_max_turbidity CONSTANT NUMBER := 4.0; -- NTU
    c_max_conductivity CONSTANT NUMBER := 2500; -- μS/cm
    c_max_nitrate CONSTANT NUMBER := 50; -- mg/L
    c_max_phosphate CONSTANT NUMBER := 0.1; -- mg/L
    c_max_coliforms CONSTANT NUMBER := 0; -- per 100ml
    
    -- Function to calculate Water Quality Index (WQI) based on Ofwat standards
    FUNCTION calculate_wqi(
        p_turbidity IN NUMBER,
        p_ph IN NUMBER,
        p_dissolved_oxygen IN NUMBER,
        p_conductivity IN NUMBER,
        p_nitrate IN NUMBER,
        p_phosphate IN NUMBER,
        p_coliforms IN NUMBER
    ) RETURN NUMBER;
    
    -- Function to check if water quality meets Ofwat standards
    FUNCTION check_ofwat_compliance(
        p_turbidity IN NUMBER,
        p_ph IN NUMBER,
        p_dissolved_oxygen IN NUMBER,
        p_conductivity IN NUMBER,
        p_nitrate IN NUMBER,
        p_phosphate IN NUMBER,
        p_coliforms IN NUMBER
    ) RETURN VARCHAR2;
    
    -- Function to check if maintenance is needed based on Ofwat guidelines
    FUNCTION check_maintenance_needed(
        p_device_id IN VARCHAR2
    ) RETURN BOOLEAN;
    
    -- Procedure to update device status
    PROCEDURE update_device_status(
        p_device_id IN VARCHAR2,
        p_status IN VARCHAR2
    );
    
    -- Procedure to record water quality incident
    PROCEDURE record_incident(
        p_device_id IN VARCHAR2,
        p_incident_type IN VARCHAR2,
        p_description IN VARCHAR2,
        p_severity IN VARCHAR2
    );
END water_quality_pkg;
/

CREATE OR REPLACE PACKAGE BODY water_quality_pkg AS
    FUNCTION calculate_wqi(
        p_turbidity IN NUMBER,
        p_ph IN NUMBER,
        p_dissolved_oxygen IN NUMBER,
        p_conductivity IN NUMBER,
        p_nitrate IN NUMBER,
        p_phosphate IN NUMBER,
        p_coliforms IN NUMBER
    ) RETURN NUMBER IS
        v_wqi NUMBER;
        v_turbidity_score NUMBER;
        v_ph_score NUMBER;
        v_oxygen_score NUMBER;
        v_conductivity_score NUMBER;
        v_nitrate_score NUMBER;
        v_phosphate_score NUMBER;
        v_coliforms_score NUMBER;
    BEGIN
        -- Calculate individual parameter scores (0-100)
        
        -- Turbidity score (weight: 15%)
        v_turbidity_score := CASE
            WHEN p_turbidity <= 1 THEN 100
            WHEN p_turbidity <= 2 THEN 80
            WHEN p_turbidity <= 3 THEN 60
            WHEN p_turbidity <= 4 THEN 40
            ELSE 0
        END;
        
        -- pH score (weight: 15%)
        v_ph_score := CASE
            WHEN p_ph BETWEEN 6.5 AND 9.5 THEN 100
            WHEN p_ph BETWEEN 6.0 AND 10.0 THEN 60
            ELSE 0
        END;
        
        -- Dissolved Oxygen score (weight: 15%)
        v_oxygen_score := CASE
            WHEN p_dissolved_oxygen >= 8 THEN 100
            WHEN p_dissolved_oxygen >= 6 THEN 80
            WHEN p_dissolved_oxygen >= 5 THEN 60
            ELSE 0
        END;
        
        -- Conductivity score (weight: 10%)
        v_conductivity_score := CASE
            WHEN p_conductivity <= 1000 THEN 100
            WHEN p_conductivity <= 1500 THEN 80
            WHEN p_conductivity <= 2000 THEN 60
            WHEN p_conductivity <= 2500 THEN 40
            ELSE 0
        END;
        
        -- Nitrate score (weight: 15%)
        v_nitrate_score := CASE
            WHEN p_nitrate <= 25 THEN 100
            WHEN p_nitrate <= 35 THEN 80
            WHEN p_nitrate <= 45 THEN 60
            WHEN p_nitrate <= 50 THEN 40
            ELSE 0
        END;
        
        -- Phosphate score (weight: 15%)
        v_phosphate_score := CASE
            WHEN p_phosphate <= 0.05 THEN 100
            WHEN p_phosphate <= 0.08 THEN 80
            WHEN p_phosphate <= 0.1 THEN 60
            ELSE 0
        END;
        
        -- Coliforms score (weight: 15%)
        v_coliforms_score := CASE
            WHEN p_coliforms = 0 THEN 100
            ELSE 0
        END;
        
        -- Calculate weighted WQI
        v_wqi := (
            (v_turbidity_score * 0.15) +
            (v_ph_score * 0.15) +
            (v_oxygen_score * 0.15) +
            (v_conductivity_score * 0.10) +
            (v_nitrate_score * 0.15) +
            (v_phosphate_score * 0.15) +
            (v_coliforms_score * 0.15)
        );
        
        RETURN v_wqi;
    END calculate_wqi;
    
    FUNCTION check_ofwat_compliance(
        p_turbidity IN NUMBER,
        p_ph IN NUMBER,
        p_dissolved_oxygen IN NUMBER,
        p_conductivity IN NUMBER,
        p_nitrate IN NUMBER,
        p_phosphate IN NUMBER,
        p_coliforms IN NUMBER
    ) RETURN VARCHAR2 IS
        v_compliance_status VARCHAR2(20);
        v_violations NUMBER := 0;
    BEGIN
        -- Check each parameter against Ofwat standards
        IF p_turbidity > c_max_turbidity THEN v_violations := v_violations + 1; END IF;
        IF p_ph < c_min_ph OR p_ph > c_max_ph THEN v_violations := v_violations + 1; END IF;
        IF p_dissolved_oxygen < c_min_dissolved_oxygen THEN v_violations := v_violations + 1; END IF;
        IF p_conductivity > c_max_conductivity THEN v_violations := v_violations + 1; END IF;
        IF p_nitrate > c_max_nitrate THEN v_violations := v_violations + 1; END IF;
        IF p_phosphate > c_max_phosphate THEN v_violations := v_violations + 1; END IF;
        IF p_coliforms > c_max_coliforms THEN v_violations := v_violations + 1; END IF;
        
        -- Determine compliance status
        CASE v_violations
            WHEN 0 THEN v_compliance_status := 'COMPLIANT';
            WHEN 1 THEN v_compliance_status := 'MINOR_VIOLATION';
            ELSE v_compliance_status := 'MAJOR_VIOLATION';
        END CASE;
        
        RETURN v_compliance_status;
    END check_ofwat_compliance;
    
    FUNCTION check_maintenance_needed(
        p_device_id IN VARCHAR2
    ) RETURN BOOLEAN IS
        v_last_maintenance DATE;
        v_maintenance_interval NUMBER := 30; -- Default 30 days
        v_device_type VARCHAR2(50);
    BEGIN
        -- Get device type and last maintenance date
        SELECT d.device_type, MAX(m.completed_date)
        INTO v_device_type, v_last_maintenance
        FROM industrial_iot_data d
        LEFT JOIN industrial_maintenance m ON d.device_id = m.device_id
        WHERE d.device_id = p_device_id
        AND m.status = 'COMPLETED'
        GROUP BY d.device_type;
        
        -- Adjust maintenance interval based on device type
        CASE v_device_type
            WHEN 'Water Quality Sensor' THEN v_maintenance_interval := 14; -- More frequent for quality sensors
            WHEN 'Flow Meter' THEN v_maintenance_interval := 45; -- Less frequent for flow meters
            WHEN 'Pressure Gauge' THEN v_maintenance_interval := 60; -- Less frequent for pressure gauges
            WHEN 'Water Pump' THEN v_maintenance_interval := 90; -- Less frequent for pumps
        END CASE;
        
        RETURN (v_last_maintenance IS NULL OR 
                (SYSDATE - v_last_maintenance) > v_maintenance_interval);
    END check_maintenance_needed;
    
    PROCEDURE update_device_status(
        p_device_id IN VARCHAR2,
        p_status IN VARCHAR2
    ) IS
    BEGIN
        UPDATE industrial_iot_data
        SET status = p_status,
            updated_at = SYSTIMESTAMP
        WHERE device_id = p_device_id;
        
        COMMIT;
    END update_device_status;
    
    PROCEDURE record_incident(
        p_device_id IN VARCHAR2,
        p_incident_type IN VARCHAR2,
        p_description IN VARCHAR2,
        p_severity IN VARCHAR2
    ) IS
        v_incident_id VARCHAR2(50);
    BEGIN
        -- Generate incident ID
        v_incident_id := 'INC' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS');
        
        -- Insert incident record
        INSERT INTO industrial_safety (
            safety_id,
            device_id,
            incident_type,
            description,
            severity,
            incident_date,
            status
        ) VALUES (
            v_incident_id,
            p_device_id,
            p_incident_type,
            p_description,
            p_severity,
            SYSTIMESTAMP,
            'OPEN'
        );
        
        -- Update device status if necessary
        IF p_severity IN ('HIGH', 'CRITICAL') THEN
            update_device_status(p_device_id, 'MAINTENANCE_REQUIRED');
        END IF;
        
        COMMIT;
    END record_incident;
END water_quality_pkg;
/

-- Create trigger for automatic maintenance scheduling
CREATE OR REPLACE TRIGGER trg_schedule_maintenance
AFTER INSERT ON industrial_performance
FOR EACH ROW
DECLARE
    v_needs_maintenance BOOLEAN;
BEGIN
    v_needs_maintenance := water_quality_pkg.check_maintenance_needed(:NEW.device_id);
    
    IF v_needs_maintenance THEN
        INSERT INTO industrial_maintenance (
            maintenance_id,
            device_id,
            maintenance_type,
            scheduled_date,
            status,
            description
        ) VALUES (
            'MAINT' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS'),
            :NEW.device_id,
            'Preventive Maintenance',
            SYSDATE + 7, -- Schedule for 7 days from now
            'SCHEDULED',
            'Automatically scheduled based on performance metrics'
        );
    END IF;
END;
/

-- Create procedure for workforce scheduling
CREATE OR REPLACE PROCEDURE schedule_workforce(
    p_department IN VARCHAR2,
    p_shift_date IN DATE,
    p_shift_type IN VARCHAR2
) IS
    v_employee_id VARCHAR2(50);
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
BEGIN
    -- Get available employees for the department
    FOR emp IN (
        SELECT employee_id
        FROM employees
        WHERE department = p_department
        AND status = 'ACTIVE'
        AND employee_id NOT IN (
            SELECT employee_id
            FROM workforce_scheduling
            WHERE shift_date = p_shift_date
        )
    ) LOOP
        -- Calculate shift times based on shift type
        CASE p_shift_type
            WHEN 'MORNING' THEN
                v_start_time := p_shift_date + INTERVAL '6' HOUR;
                v_end_time := p_shift_date + INTERVAL '14' HOUR;
            WHEN 'AFTERNOON' THEN
                v_start_time := p_shift_date + INTERVAL '14' HOUR;
                v_end_time := p_shift_date + INTERVAL '22' HOUR;
            WHEN 'NIGHT' THEN
                v_start_time := p_shift_date + INTERVAL '22' HOUR;
                v_end_time := p_shift_date + INTERVAL '6' HOUR + INTERVAL '1' DAY;
        END CASE;
        
        -- Insert schedule
        INSERT INTO workforce_scheduling (
            schedule_id,
            employee_id,
            shift_date,
            shift_type,
            start_time,
            end_time,
            department,
            status
        ) VALUES (
            'SCH' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS'),
            emp.employee_id,
            p_shift_date,
            p_shift_type,
            v_start_time,
            v_end_time,
            p_department,
            'SCHEDULED'
        );
    END LOOP;
    
    COMMIT;
END;
/

-- Update the real-time monitoring view to include Ofwat compliance
CREATE OR REPLACE VIEW v_real_time_monitoring AS
SELECT 
    d.device_id,
    d.device_name,
    d.device_type,
    d.location,
    p.metric_name,
    p.metric_value,
    p.unit,
    p.measurement_time,
    water_quality_pkg.check_ofwat_compliance(
        MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
    ) as ofwat_compliance,
    CASE 
        WHEN p.metric_name = 'Water Quality Index' AND p.metric_value < 50 THEN 'CRITICAL'
        WHEN p.metric_name = 'Water Quality Index' AND p.metric_value < 70 THEN 'WARNING'
        WHEN p.metric_name = 'Water Pressure' AND p.metric_value < 20 THEN 'CRITICAL'
        WHEN p.metric_name = 'Water Pressure' AND p.metric_value < 40 THEN 'WARNING'
        ELSE 'NORMAL'
    END as status
FROM industrial_iot_data d
JOIN industrial_performance p ON d.device_id = p.device_id
WHERE p.measurement_time >= SYSTIMESTAMP - INTERVAL '1' HOUR
GROUP BY d.device_id, d.device_name, d.device_type, d.location, p.metric_name, p.metric_value, p.unit, p.measurement_time;

-- Create view for Ofwat compliance reporting
CREATE OR REPLACE VIEW v_ofwat_compliance_report AS
SELECT 
    d.location,
    COUNT(DISTINCT d.device_id) as total_devices,
    COUNT(DISTINCT CASE WHEN water_quality_pkg.check_ofwat_compliance(
        MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
    ) = 'COMPLIANT' THEN d.device_id END) as compliant_devices,
    COUNT(DISTINCT CASE WHEN water_quality_pkg.check_ofwat_compliance(
        MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
    ) = 'MINOR_VIOLATION' THEN d.device_id END) as minor_violations,
    COUNT(DISTINCT CASE WHEN water_quality_pkg.check_ofwat_compliance(
        MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
        MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
    ) = 'MAJOR_VIOLATION' THEN d.device_id END) as major_violations
FROM industrial_iot_data d
JOIN industrial_performance p ON d.device_id = p.device_id
WHERE p.measurement_time >= SYSTIMESTAMP - INTERVAL '24' HOUR
GROUP BY d.location;

-- Verify the created objects
SELECT object_name, object_type 
FROM user_objects 
WHERE object_type IN ('VIEW', 'PROCEDURE', 'FUNCTION', 'PACKAGE', 'TRIGGER')
ORDER BY object_type, object_name;

EXIT; 