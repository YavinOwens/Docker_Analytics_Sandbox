WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Update industrial_iot_data table to include Ofwat-specific fields
ALTER TABLE industrial_iot_data ADD (
    ofwat_compliance_status VARCHAR2(20),
    last_compliance_check TIMESTAMP,
    water_quality_index NUMBER,
    CONSTRAINT chk_ofwat_status CHECK (ofwat_compliance_status IN ('COMPLIANT', 'MINOR_VIOLATION', 'MAJOR_VIOLATION'))
);

-- Update industrial_performance table to include Ofwat metrics
ALTER TABLE industrial_performance ADD (
    is_ofwat_metric CHAR(1) DEFAULT 'N',
    threshold_min NUMBER,
    threshold_max NUMBER,
    CONSTRAINT chk_ofwat_metric CHECK (is_ofwat_metric IN ('Y', 'N'))
);

-- Insert Ofwat standard metrics into industrial_performance
INSERT INTO industrial_performance (
    performance_id,
    device_id,
    metric_name,
    metric_value,
    unit,
    measurement_time,
    is_ofwat_metric,
    threshold_min,
    threshold_max
)
SELECT 
    'PERF' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS') || ROWNUM,
    d.device_id,
    m.metric_name,
    CASE 
        WHEN m.metric_name = 'Turbidity' THEN DBMS_RANDOM.VALUE(0, 5)
        WHEN m.metric_name = 'pH' THEN DBMS_RANDOM.VALUE(6, 10)
        WHEN m.metric_name = 'Dissolved Oxygen' THEN DBMS_RANDOM.VALUE(4, 9)
        WHEN m.metric_name = 'Conductivity' THEN DBMS_RANDOM.VALUE(500, 3000)
        WHEN m.metric_name = 'Nitrate' THEN DBMS_RANDOM.VALUE(0, 60)
        WHEN m.metric_name = 'Phosphate' THEN DBMS_RANDOM.VALUE(0, 0.2)
        WHEN m.metric_name = 'Coliforms' THEN FLOOR(DBMS_RANDOM.VALUE(0, 2))
    END as metric_value,
    CASE 
        WHEN m.metric_name = 'Turbidity' THEN 'NTU'
        WHEN m.metric_name = 'pH' THEN 'pH'
        WHEN m.metric_name = 'Dissolved Oxygen' THEN 'mg/L'
        WHEN m.metric_name = 'Conductivity' THEN 'μS/cm'
        WHEN m.metric_name = 'Nitrate' THEN 'mg/L'
        WHEN m.metric_name = 'Phosphate' THEN 'mg/L'
        WHEN m.metric_name = 'Coliforms' THEN 'per 100ml'
    END as unit,
    SYSTIMESTAMP - DBMS_RANDOM.VALUE(0, 24) * INTERVAL '1' HOUR as measurement_time,
    'Y' as is_ofwat_metric,
    CASE 
        WHEN m.metric_name = 'Turbidity' THEN 0
        WHEN m.metric_name = 'pH' THEN 6.5
        WHEN m.metric_name = 'Dissolved Oxygen' THEN 5.0
        WHEN m.metric_name = 'Conductivity' THEN 0
        WHEN m.metric_name = 'Nitrate' THEN 0
        WHEN m.metric_name = 'Phosphate' THEN 0
        WHEN m.metric_name = 'Coliforms' THEN 0
    END as threshold_min,
    CASE 
        WHEN m.metric_name = 'Turbidity' THEN 4.0
        WHEN m.metric_name = 'pH' THEN 9.5
        WHEN m.metric_name = 'Dissolved Oxygen' THEN NULL
        WHEN m.metric_name = 'Conductivity' THEN 2500
        WHEN m.metric_name = 'Nitrate' THEN 50
        WHEN m.metric_name = 'Phosphate' THEN 0.1
        WHEN m.metric_name = 'Coliforms' THEN 0
    END as threshold_max
FROM industrial_iot_data d
CROSS JOIN (
    SELECT 'Turbidity' as metric_name FROM DUAL UNION ALL
    SELECT 'pH' FROM DUAL UNION ALL
    SELECT 'Dissolved Oxygen' FROM DUAL UNION ALL
    SELECT 'Conductivity' FROM DUAL UNION ALL
    SELECT 'Nitrate' FROM DUAL UNION ALL
    SELECT 'Phosphate' FROM DUAL UNION ALL
    SELECT 'Coliforms' FROM DUAL
) m
WHERE d.device_type IN ('Water Quality Sensor', 'Flow Meter');

-- Update industrial_maintenance table to include Ofwat-specific maintenance types
ALTER TABLE industrial_maintenance ADD (
    ofwat_compliance_related CHAR(1) DEFAULT 'N',
    compliance_issue_type VARCHAR2(50),
    CONSTRAINT chk_ofwat_maintenance CHECK (ofwat_compliance_related IN ('Y', 'N'))
);

-- Insert Ofwat-specific maintenance records
INSERT INTO industrial_maintenance (
    maintenance_id,
    device_id,
    maintenance_type,
    scheduled_date,
    status,
    description,
    ofwat_compliance_related,
    compliance_issue_type
)
SELECT 
    'MAINT' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS') || ROWNUM,
    d.device_id,
    CASE 
        WHEN water_quality_pkg.check_ofwat_compliance(
            MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
        ) = 'MAJOR_VIOLATION' THEN 'Emergency Ofwat Compliance'
        WHEN water_quality_pkg.check_ofwat_compliance(
            MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
        ) = 'MINOR_VIOLATION' THEN 'Preventive Ofwat Compliance'
        ELSE 'Routine Ofwat Compliance'
    END as maintenance_type,
    SYSDATE + DBMS_RANDOM.VALUE(1, 30) as scheduled_date,
    'SCHEDULED' as status,
    'Maintenance required to ensure Ofwat compliance' as description,
    'Y' as ofwat_compliance_related,
    CASE 
        WHEN MAX(CASE WHEN p.metric_name = 'Turbidity' AND p.metric_value > 4.0 THEN 1 ELSE 0 END) = 1 THEN 'High Turbidity'
        WHEN MAX(CASE WHEN p.metric_name = 'pH' AND (p.metric_value < 6.5 OR p.metric_value > 9.5) THEN 1 ELSE 0 END) = 1 THEN 'pH Out of Range'
        WHEN MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' AND p.metric_value < 5.0 THEN 1 ELSE 0 END) = 1 THEN 'Low Dissolved Oxygen'
        WHEN MAX(CASE WHEN p.metric_name = 'Conductivity' AND p.metric_value > 2500 THEN 1 ELSE 0 END) = 1 THEN 'High Conductivity'
        WHEN MAX(CASE WHEN p.metric_name = 'Nitrate' AND p.metric_value > 50 THEN 1 ELSE 0 END) = 1 THEN 'High Nitrate'
        WHEN MAX(CASE WHEN p.metric_name = 'Phosphate' AND p.metric_value > 0.1 THEN 1 ELSE 0 END) = 1 THEN 'High Phosphate'
        WHEN MAX(CASE WHEN p.metric_name = 'Coliforms' AND p.metric_value > 0 THEN 1 ELSE 0 END) = 1 THEN 'Coliforms Present'
        ELSE 'General Compliance'
    END as compliance_issue_type
FROM industrial_iot_data d
JOIN industrial_performance p ON d.device_id = p.device_id
WHERE p.is_ofwat_metric = 'Y'
GROUP BY d.device_id
HAVING water_quality_pkg.check_ofwat_compliance(
    MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
) != 'COMPLIANT';

-- Update industrial_safety table to include Ofwat-specific incidents
ALTER TABLE industrial_safety ADD (
    ofwat_related CHAR(1) DEFAULT 'N',
    compliance_impact VARCHAR2(50),
    CONSTRAINT chk_ofwat_safety CHECK (ofwat_related IN ('Y', 'N'))
);

-- Insert Ofwat-specific safety incidents
INSERT INTO industrial_safety (
    safety_id,
    device_id,
    incident_type,
    description,
    severity,
    incident_date,
    status,
    ofwat_related,
    compliance_impact
)
SELECT 
    'SAFE' || TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISS') || ROWNUM,
    d.device_id,
    CASE 
        WHEN water_quality_pkg.check_ofwat_compliance(
            MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
        ) = 'MAJOR_VIOLATION' THEN 'Critical Ofwat Violation'
        WHEN water_quality_pkg.check_ofwat_compliance(
            MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
        ) = 'MINOR_VIOLATION' THEN 'Minor Ofwat Violation'
        ELSE 'Ofwat Compliance Warning'
    END as incident_type,
    'Water quality parameters outside Ofwat guidelines' as description,
    CASE 
        WHEN water_quality_pkg.check_ofwat_compliance(
            MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
        ) = 'MAJOR_VIOLATION' THEN 'CRITICAL'
        WHEN water_quality_pkg.check_ofwat_compliance(
            MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
            MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
        ) = 'MINOR_VIOLATION' THEN 'HIGH'
        ELSE 'MEDIUM'
    END as severity,
    SYSTIMESTAMP - DBMS_RANDOM.VALUE(0, 24) * INTERVAL '1' HOUR as incident_date,
    'OPEN' as status,
    'Y' as ofwat_related,
    CASE 
        WHEN MAX(CASE WHEN p.metric_name = 'Coliforms' AND p.metric_value > 0 THEN 1 ELSE 0 END) = 1 THEN 'Public Health Risk'
        WHEN MAX(CASE WHEN p.metric_name = 'Nitrate' AND p.metric_value > 50 THEN 1 ELSE 0 END) = 1 THEN 'Chemical Contamination'
        WHEN MAX(CASE WHEN p.metric_name = 'Turbidity' AND p.metric_value > 4.0 THEN 1 ELSE 0 END) = 1 THEN 'Water Clarity Issue'
        ELSE 'General Compliance Impact'
    END as compliance_impact
FROM industrial_iot_data d
JOIN industrial_performance p ON d.device_id = p.device_id
WHERE p.is_ofwat_metric = 'Y'
GROUP BY d.device_id
HAVING water_quality_pkg.check_ofwat_compliance(
    MAX(CASE WHEN p.metric_name = 'Turbidity' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'pH' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Dissolved Oxygen' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Conductivity' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Nitrate' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Phosphate' THEN p.metric_value END),
    MAX(CASE WHEN p.metric_name = 'Coliforms' THEN p.metric_value END)
) != 'COMPLIANT';

-- Verify the updates
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN (
    'INDUSTRIAL_IOT_DATA',
    'INDUSTRIAL_PERFORMANCE',
    'INDUSTRIAL_MAINTENANCE',
    'INDUSTRIAL_SAFETY'
);

-- Check Ofwat compliance status
SELECT 
    d.device_id,
    d.device_name,
    d.device_type,
    d.ofwat_compliance_status,
    d.water_quality_index,
    d.last_compliance_check
FROM industrial_iot_data d
WHERE d.ofwat_compliance_status IS NOT NULL
ORDER BY d.last_compliance_check DESC;

EXIT; 