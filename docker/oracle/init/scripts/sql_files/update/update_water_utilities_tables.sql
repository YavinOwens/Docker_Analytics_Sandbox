-- Connect to the database
CONNECT app_user/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Update departments and positions in employees table
UPDATE employees 
SET department = CASE 
    WHEN department LIKE '%MANAGEMENT%' THEN 'Executive'
    WHEN department LIKE '%TECHNICAL%' THEN 'Water Treatment'
    WHEN department LIKE '%ADMIN%' THEN 'Customer Service'
    ELSE 'Distribution'
END,
position = CASE 
    WHEN position LIKE '%MANAGER%' THEN 'Plant Manager'
    WHEN position LIKE '%TECH%' THEN 'Field Technician'
    WHEN position LIKE '%ADMIN%' THEN 'Customer Service Representative'
    ELSE 'Operator'
END,
email = REPLACE(email, '@company.com', '@waterutilities.com');

-- Update industrial_iot_data with water utilities specific devices
UPDATE industrial_iot_data 
SET device_type = CASE 
    WHEN device_type LIKE '%SENSOR%' THEN 'Water Quality Sensor'
    WHEN device_type LIKE '%METER%' THEN 'Flow Meter'
    WHEN device_type LIKE '%PUMP%' THEN 'Water Pump'
    ELSE 'Pressure Gauge'
END,
location = CASE 
    WHEN location LIKE '%TANK%' THEN 'Water Storage Tank'
    WHEN location LIKE '%PLANT%' THEN 'Treatment Plant'
    WHEN location LIKE '%PIPE%' THEN 'Distribution Line'
    ELSE 'Service Point'
END;

-- Update industrial_maintenance with water utilities specific maintenance types
UPDATE industrial_maintenance 
SET maintenance_type = CASE 
    WHEN maintenance_type LIKE '%CHECK%' THEN 'Water Quality Check'
    WHEN maintenance_type LIKE '%REPAIR%' THEN 'Pipe Repair'
    WHEN maintenance_type LIKE '%CLEAN%' THEN 'Tank Cleaning'
    ELSE 'Pump Maintenance'
END,
description = CASE 
    WHEN description LIKE '%CHECK%' THEN 'Routine water quality monitoring and testing'
    WHEN description LIKE '%REPAIR%' THEN 'Distribution system repair and maintenance'
    WHEN description LIKE '%CLEAN%' THEN 'Water storage tank cleaning and inspection'
    ELSE 'Pump system maintenance and calibration'
END;

-- Update industrial_performance with water utilities specific metrics
UPDATE industrial_performance 
SET metric_name = CASE 
    WHEN metric_name LIKE '%FLOW%' THEN 'Water Flow Rate'
    WHEN metric_name LIKE '%PRESSURE%' THEN 'Water Pressure'
    WHEN metric_name LIKE '%QUALITY%' THEN 'Water Quality Index'
    ELSE 'Turbidity Level'
END,
unit = CASE 
    WHEN metric_name LIKE '%FLOW%' THEN 'GPM'
    WHEN metric_name LIKE '%PRESSURE%' THEN 'PSI'
    WHEN metric_name LIKE '%QUALITY%' THEN 'WQI'
    ELSE 'NTU'
END;

-- Update industrial_safety with water utilities specific incidents
UPDATE industrial_safety 
SET incident_type = CASE 
    WHEN incident_type LIKE '%LEAK%' THEN 'Water Leak'
    WHEN incident_type LIKE '%CONTAM%' THEN 'Water Contamination'
    WHEN incident_type LIKE '%PRESSURE%' THEN 'Pressure Fluctuation'
    ELSE 'Equipment Failure'
END,
severity_level = CASE 
    WHEN severity_level = 'HIGH' THEN 'Critical'
    WHEN severity_level = 'MEDIUM' THEN 'Major'
    ELSE 'Minor'
END;

-- Update workforce_attendance with water utilities specific notes
UPDATE workforce_attendance 
SET notes = CASE 
    WHEN notes LIKE '%CHECK%' THEN 'Water quality monitoring completed'
    WHEN notes LIKE '%REPAIR%' THEN 'Distribution system maintenance performed'
    WHEN notes LIKE '%INSPECT%' THEN 'Water treatment facility inspection'
    ELSE 'Routine system check completed'
END;

-- Update workforce_skills with water utilities specific skills
UPDATE workforce_skills 
SET skill_name = CASE 
    WHEN skill_name LIKE '%TECH%' THEN 'Water Treatment Technology'
    WHEN skill_name LIKE '%SAFETY%' THEN 'Water Safety Protocol'
    WHEN skill_name LIKE '%MAINT%' THEN 'Water System Maintenance'
    ELSE 'Water Quality Analysis'
END,
proficiency_level = CASE 
    WHEN proficiency_level = 'EXPERT' THEN 'Master'
    WHEN proficiency_level = 'ADVANCED' THEN 'Expert'
    ELSE 'Proficient'
END;

-- Update workforce_training with water utilities specific training
UPDATE workforce_training 
SET training_name = CASE 
    WHEN training_name LIKE '%SAFETY%' THEN 'Water Safety and Emergency Response'
    WHEN training_name LIKE '%TECH%' THEN 'Water Treatment Technology'
    WHEN training_name LIKE '%QUALITY%' THEN 'Water Quality Management'
    ELSE 'Distribution System Operations'
END,
training_type = CASE 
    WHEN training_type LIKE '%SAFETY%' THEN 'Safety Certification'
    WHEN training_type LIKE '%TECH%' THEN 'Technical Training'
    ELSE 'Operational Training'
END;

-- Update workforce_scheduling with water utilities specific shifts
UPDATE workforce_scheduling 
SET shift_type = CASE 
    WHEN shift_type LIKE '%DAY%' THEN 'Treatment Plant Day Shift'
    WHEN shift_type LIKE '%NIGHT%' THEN 'Treatment Plant Night Shift'
    WHEN shift_type LIKE '%MAINT%' THEN 'Maintenance Shift'
    ELSE 'Distribution Shift'
END;

-- Verify the updates
SELECT 'Employees' as table_name, COUNT(*) as count FROM employees UNION ALL
SELECT 'Industrial IoT Data', COUNT(*) FROM industrial_iot_data UNION ALL
SELECT 'Industrial Maintenance', COUNT(*) FROM industrial_maintenance UNION ALL
SELECT 'Industrial Performance', COUNT(*) FROM industrial_performance UNION ALL
SELECT 'Industrial Safety', COUNT(*) FROM industrial_safety UNION ALL
SELECT 'Workforce Attendance', COUNT(*) FROM workforce_attendance UNION ALL
SELECT 'Workforce Skills', COUNT(*) FROM workforce_skills UNION ALL
SELECT 'Workforce Training', COUNT(*) FROM workforce_training UNION ALL
SELECT 'Workforce Scheduling', COUNT(*) FROM workforce_scheduling;

-- Display sample of updated data
SELECT 'Employees' as table_name, department, COUNT(*) as count 
FROM employees 
GROUP BY department 
ORDER BY department;

SELECT 'Industrial IoT Data' as table_name, device_type, COUNT(*) as count 
FROM industrial_iot_data 
GROUP BY device_type 
ORDER BY device_type;

SELECT 'Workforce Skills' as table_name, skill_name, COUNT(*) as count 
FROM workforce_skills 
GROUP BY skill_name 
ORDER BY skill_name;

EXIT; 