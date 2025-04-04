WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Create notification table for automated alerts
CREATE TABLE compliance_notifications (
    notification_id VARCHAR2(50) PRIMARY KEY,
    device_id VARCHAR2(50),
    notification_type VARCHAR2(50),
    message VARCHAR2(500),
    severity VARCHAR2(20),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    status VARCHAR2(20) DEFAULT 'NEW',
    CONSTRAINT fk_notification_device FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id),
    CONSTRAINT chk_notification_status CHECK (status IN ('NEW', 'SENT', 'ACKNOWLEDGED', 'RESOLVED'))
);

-- Create UK standards compliance view
CREATE OR REPLACE VIEW v_uk_standards_compliance AS
SELECT 
    d.device_id,
    d.device_name,
    d.device_type,
    d.location,
    d.ofwat_compliance_status,
    d.water_quality_index,
    d.last_compliance_check,
    COUNT(DISTINCT CASE WHEN p.is_ofwat_metric = 'Y' THEN p.performance_id END) as total_metrics,
    COUNT(DISTINCT CASE WHEN p.is_ofwat_metric = 'Y' AND p.metric_value BETWEEN p.threshold_min AND p.threshold_max THEN p.performance_id END) as compliant_metrics,
    COUNT(DISTINCT CASE WHEN p.is_ofwat_metric = 'Y' AND p.metric_value NOT BETWEEN p.threshold_min AND p.threshold_max THEN p.performance_id END) as non_compliant_metrics,
    MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END) as current_turbidity,
    MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END) as current_ph,
    MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END) as current_dissolved_oxygen,
    MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END) as current_conductivity,
    MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END) as current_nitrate,
    MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END) as current_phosphate,
    MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END) as current_coliforms
FROM industrial_iot_data d
LEFT JOIN industrial_performance p ON d.device_id = p.device_id
GROUP BY d.device_id, d.device_name, d.device_type, d.location, d.ofwat_compliance_status, d.water_quality_index, d.last_compliance_check;

-- Create detailed incident tracking view
CREATE OR REPLACE VIEW v_detailed_incidents AS
SELECT 
    s.safety_id,
    s.device_id,
    d.device_name,
    d.device_type,
    d.location,
    s.incident_type,
    s.description,
    s.severity,
    s.incident_date,
    s.status,
    s.ofwat_related,
    s.compliance_impact,
    m.maintenance_id,
    m.maintenance_type,
    m.scheduled_date,
    m.status as maintenance_status,
    m.ofwat_compliance_related,
    m.compliance_issue_type,
    COUNT(DISTINCT n.notification_id) as notification_count,
    MAX(n.created_at) as last_notification_time
FROM industrial_safety s
JOIN industrial_iot_data d ON s.device_id = d.device_id
LEFT JOIN industrial_maintenance m ON s.device_id = m.device_id
LEFT JOIN compliance_notifications n ON s.device_id = n.device_id
GROUP BY 
    s.safety_id, s.device_id, d.device_name, d.device_type, d.location,
    s.incident_type, s.description, s.severity, s.incident_date, s.status,
    s.ofwat_related, s.compliance_impact, m.maintenance_id, m.maintenance_type,
    m.scheduled_date, m.status, m.ofwat_compliance_related, m.compliance_issue_type;

-- Create procedure for automated notifications
CREATE OR REPLACE PROCEDURE generate_compliance_notifications IS
    v_notification_id VARCHAR2(50);
BEGIN
    -- Check for major violations
    FOR violation IN (
        SELECT 
            d.device_id,
            d.device_name,
            d.device_type,
            p.metric_name,
            p.metric_value,
            p.threshold_min,
            p.threshold_max,
            p.unit
        FROM industrial_iot_data d
        JOIN industrial_performance p ON d.device_id = p.device_id
        WHERE p.is_ofwat_metric = 'Y'
        AND (
            (p.metric_name = 'Coliforms' AND p.metric_value > 0) OR
            (p.metric_name = 'Turbidity' AND p.metric_value > 4.0) OR
            (p.metric_name = 'pH' AND (p.metric_value < 6.5 OR p.metric_value > 9.5)) OR
            (p.metric_name = 'Dissolved Oxygen' AND p.metric_value < 5.0) OR
            (p.metric_name = 'Conductivity' AND p.metric_value > 2500) OR
            (p.metric_name = 'Nitrate' AND p.metric_value > 50) OR
            (p.metric_name = 'Phosphate' AND p.metric_value > 0.1)
        )
    ) LOOP
        v_notification_id := 'NOTIF' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS') || ROWNUM;
        
        INSERT INTO compliance_notifications (
            notification_id,
            device_id,
            notification_type,
            message,
            severity
        ) VALUES (
            v_notification_id,
            violation.device_id,
            'UK_STANDARDS_VIOLATION',
            'Critical violation detected: ' || violation.metric_name || ' = ' || 
            violation.metric_value || ' ' || violation.unit || 
            ' (Threshold: ' || NVL(TO_CHAR(violation.threshold_min), 'N/A') || ' - ' || 
            NVL(TO_CHAR(violation.threshold_max), 'N/A') || ')',
            CASE 
                WHEN violation.metric_name = 'Coliforms' THEN 'CRITICAL'
                WHEN violation.metric_name IN ('Turbidity', 'pH') THEN 'HIGH'
                ELSE 'MEDIUM'
            END
        );
    END LOOP;
    
    -- Check for maintenance due
    FOR maintenance IN (
        SELECT 
            d.device_id,
            d.device_name,
            d.device_type,
            m.maintenance_id,
            m.scheduled_date
        FROM industrial_iot_data d
        JOIN industrial_maintenance m ON d.device_id = m.device_id
        WHERE m.status = 'SCHEDULED'
        AND m.scheduled_date <= SYSDATE + 7
    ) LOOP
        v_notification_id := 'NOTIF' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS') || ROWNUM;
        
        INSERT INTO compliance_notifications (
            notification_id,
            device_id,
            notification_type,
            message,
            severity
        ) VALUES (
            v_notification_id,
            maintenance.device_id,
            'MAINTENANCE_DUE',
            'Maintenance scheduled for ' || maintenance.device_name || ' on ' || 
            TO_CHAR(maintenance.scheduled_date, 'YYYY-MM-DD'),
            'MEDIUM'
        );
    END LOOP;
    
    COMMIT;
END;
/

-- Create job to run notifications every hour
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name => 'COMPLIANCE_NOTIFICATIONS_JOB',
        job_type => 'STORED_PROCEDURE',
        job_action => 'generate_compliance_notifications',
        repeat_interval => 'FREQ=HOURLY',
        enabled => TRUE
    );
END;
/

-- Create view for compliance trends
CREATE OR REPLACE VIEW v_compliance_trends AS
SELECT 
    d.device_id,
    d.device_name,
    d.device_type,
    d.location,
    TRUNC(p.measurement_time, 'HH24') as measurement_hour,
    COUNT(DISTINCT CASE WHEN p.metric_value BETWEEN p.threshold_min AND p.threshold_max THEN p.performance_id END) as compliant_readings,
    COUNT(DISTINCT p.performance_id) as total_readings,
    AVG(p.metric_value) as avg_value,
    MIN(p.metric_value) as min_value,
    MAX(p.metric_value) as max_value
FROM industrial_iot_data d
JOIN industrial_performance p ON d.device_id = p.device_id
WHERE p.is_ofwat_metric = 'Y'
GROUP BY 
    d.device_id, d.device_name, d.device_type, d.location,
    TRUNC(p.measurement_time, 'HH24');

-- Create view for compliance summary by location
CREATE OR REPLACE VIEW v_location_compliance_summary AS
SELECT 
    d.location,
    COUNT(DISTINCT d.device_id) as total_devices,
    COUNT(DISTINCT CASE WHEN d.ofwat_compliance_status = 'COMPLIANT' THEN d.device_id END) as compliant_devices,
    COUNT(DISTINCT CASE WHEN d.ofwat_compliance_status = 'MINOR_VIOLATION' THEN d.device_id END) as minor_violations,
    COUNT(DISTINCT CASE WHEN d.ofwat_compliance_status = 'MAJOR_VIOLATION' THEN d.device_id END) as major_violations,
    AVG(d.water_quality_index) as avg_water_quality_index,
    COUNT(DISTINCT CASE WHEN s.severity = 'CRITICAL' THEN s.safety_id END) as critical_incidents,
    COUNT(DISTINCT CASE WHEN s.severity = 'HIGH' THEN s.safety_id END) as high_severity_incidents,
    COUNT(DISTINCT CASE WHEN m.status = 'SCHEDULED' THEN m.maintenance_id END) as pending_maintenance
FROM industrial_iot_data d
LEFT JOIN industrial_safety s ON d.device_id = s.device_id
LEFT JOIN industrial_maintenance m ON d.device_id = m.device_id
GROUP BY d.location;

-- Verify the created objects
SELECT object_name, object_type 
FROM user_objects 
WHERE object_type IN ('VIEW', 'PROCEDURE', 'JOB')
ORDER BY object_type, object_name;

EXIT; 