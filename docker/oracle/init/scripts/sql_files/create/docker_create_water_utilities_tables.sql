WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Drop existing tables
BEGIN
   FOR r IN (SELECT table_name FROM user_tables WHERE table_name IN (
       'EMPLOYEES',
       'INDUSTRIAL_IOT_DATA',
       'INDUSTRIAL_MAINTENANCE',
       'INDUSTRIAL_PERFORMANCE',
       'INDUSTRIAL_SAFETY',
       'WORKFORCE_ATTENDANCE',
       'WORKFORCE_SKILLS',
       'WORKFORCE_TRAINING',
       'WORKFORCE_SCHEDULING'
   )) LOOP
       EXECUTE IMMEDIATE 'DROP TABLE ' || r.table_name || ' CASCADE CONSTRAINTS';
   END LOOP;
END;
/

-- Create employees table
CREATE TABLE employees (
    employee_id VARCHAR2(50) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone VARCHAR2(20),
    hire_date DATE NOT NULL,
    department VARCHAR2(50),
    position VARCHAR2(100),
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT chk_emp_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'ON_LEAVE', 'TERMINATED'))
);

-- Create industrial tables
CREATE TABLE industrial_iot_data (
    device_id VARCHAR2(50) PRIMARY KEY,
    device_name VARCHAR2(100),
    device_type VARCHAR2(50),
    location VARCHAR2(100),
    status VARCHAR2(20),
    last_reading NUMBER,
    reading_timestamp TIMESTAMP,
    battery_level NUMBER,
    signal_strength NUMBER
);

CREATE TABLE industrial_maintenance (
    maintenance_id VARCHAR2(50) PRIMARY KEY,
    device_id VARCHAR2(50),
    maintenance_type VARCHAR2(50),
    scheduled_date DATE,
    completed_date DATE,
    status VARCHAR2(20),
    technician_id VARCHAR2(50),
    description VARCHAR2(500),
    parts_replaced VARCHAR2(500),
    FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id),
    FOREIGN KEY (technician_id) REFERENCES employees(employee_id)
);

CREATE TABLE industrial_performance (
    performance_id VARCHAR2(50) PRIMARY KEY,
    device_id VARCHAR2(50),
    metric_name VARCHAR2(50),
    metric_value NUMBER,
    measurement_date DATE,
    measurement_time TIMESTAMP,
    unit VARCHAR2(20),
    status VARCHAR2(20),
    FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id)
);

CREATE TABLE industrial_safety (
    safety_id VARCHAR2(50) PRIMARY KEY,
    device_id VARCHAR2(50),
    incident_type VARCHAR2(50),
    incident_date DATE,
    severity_level VARCHAR2(20),
    description VARCHAR2(500),
    action_taken VARCHAR2(500),
    reported_by VARCHAR2(50),
    status VARCHAR2(20),
    FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id),
    FOREIGN KEY (reported_by) REFERENCES employees(employee_id)
);

-- Create workforce tables
CREATE TABLE workforce_attendance (
    attendance_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    attendance_date DATE,
    check_in_time TIMESTAMP,
    check_out_time TIMESTAMP,
    status VARCHAR2(20),
    notes VARCHAR2(500),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE workforce_skills (
    skill_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    skill_name VARCHAR2(100),
    proficiency_level VARCHAR2(20),
    certification_date DATE,
    expiry_date DATE,
    certified_by VARCHAR2(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE workforce_training (
    training_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    training_name VARCHAR2(100),
    training_type VARCHAR2(50),
    start_date DATE,
    end_date DATE,
    status VARCHAR2(20),
    completion_date DATE,
    trainer VARCHAR2(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE workforce_scheduling (
    schedule_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    shift_date DATE,
    shift_type VARCHAR2(20),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    department VARCHAR2(50),
    status VARCHAR2(20),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Insert sample water utilities employees
INSERT INTO employees (
    employee_id, first_name, last_name, email, phone, hire_date, 
    department, position, status
)
SELECT 
    'EMP' || LPAD(ROWNUM, 4, '0'),
    'FirstName' || ROWNUM,
    'LastName' || ROWNUM,
    'employee' || ROWNUM || '@waterutilities.com',
    '555-' || LPAD(ROWNUM, 4, '0'),
    TRUNC(SYSDATE) - ROUND(DBMS_RANDOM.VALUE(0, 365)),
    CASE MOD(ROWNUM, 4)
        WHEN 0 THEN 'Executive'
        WHEN 1 THEN 'Water Treatment'
        WHEN 2 THEN 'Customer Service'
        WHEN 3 THEN 'Distribution'
    END,
    CASE MOD(ROWNUM, 4)
        WHEN 0 THEN 'Plant Manager'
        WHEN 1 THEN 'Field Technician'
        WHEN 2 THEN 'Customer Service Representative'
        WHEN 3 THEN 'Operator'
    END,
    'ACTIVE'
FROM dual
CONNECT BY LEVEL <= 100;

-- Insert sample water utilities devices
INSERT INTO industrial_iot_data (
    device_id, device_name, device_type, location, status,
    last_reading, reading_timestamp, battery_level, signal_strength
)
SELECT 
    'DEV' || LPAD(ROWNUM, 4, '0'),
    'Device' || ROWNUM,
    CASE MOD(ROWNUM, 4)
        WHEN 0 THEN 'Water Quality Sensor'
        WHEN 1 THEN 'Flow Meter'
        WHEN 2 THEN 'Water Pump'
        WHEN 3 THEN 'Pressure Gauge'
    END,
    CASE MOD(ROWNUM, 4)
        WHEN 0 THEN 'Water Storage Tank'
        WHEN 1 THEN 'Treatment Plant'
        WHEN 2 THEN 'Distribution Line'
        WHEN 3 THEN 'Service Point'
    END,
    'ACTIVE',
    ROUND(DBMS_RANDOM.VALUE(1, 100), 2),
    SYSTIMESTAMP,
    ROUND(DBMS_RANDOM.VALUE(50, 100)),
    ROUND(DBMS_RANDOM.VALUE(70, 100))
FROM dual
CONNECT BY LEVEL <= 50;

-- Insert sample maintenance records
INSERT INTO industrial_maintenance (
    maintenance_id, device_id, maintenance_type, scheduled_date,
    completed_date, status, technician_id, description
)
SELECT 
    'MAINT' || LPAD(ROWNUM, 4, '0'),
    'DEV' || LPAD(MOD(ROWNUM, 50) + 1, 4, '0'),
    CASE MOD(ROWNUM, 4)
        WHEN 0 THEN 'Water Quality Check'
        WHEN 1 THEN 'Pipe Repair'
        WHEN 2 THEN 'Tank Cleaning'
        WHEN 3 THEN 'Pump Maintenance'
    END,
    TRUNC(SYSDATE) + ROWNUM,
    NULL,
    'SCHEDULED',
    'EMP' || LPAD(MOD(ROWNUM, 100) + 1, 4, '0'),
    CASE MOD(ROWNUM, 4)
        WHEN 0 THEN 'Routine water quality monitoring and testing'
        WHEN 1 THEN 'Distribution system repair and maintenance'
        WHEN 2 THEN 'Water storage tank cleaning and inspection'
        WHEN 3 THEN 'Pump system maintenance and calibration'
    END
FROM dual
CONNECT BY LEVEL <= 100;

-- Insert sample performance metrics
INSERT INTO industrial_performance (
    performance_id, device_id, metric_name, metric_value,
    measurement_date, measurement_time, unit
)
SELECT 
    'PERF' || LPAD(ROWNUM, 4, '0'),
    'DEV' || LPAD(MOD(ROWNUM, 50) + 1, 4, '0'),
    CASE MOD(ROWNUM, 4)
        WHEN 0 THEN 'Water Flow Rate'
        WHEN 1 THEN 'Water Pressure'
        WHEN 2 THEN 'Water Quality Index'
        WHEN 3 THEN 'Turbidity Level'
    END,
    ROUND(DBMS_RANDOM.VALUE(1, 100), 2),
    TRUNC(SYSDATE),
    SYSTIMESTAMP,
    CASE MOD(ROWNUM, 4)
        WHEN 0 THEN 'GPM'
        WHEN 1 THEN 'PSI'
        WHEN 2 THEN 'WQI'
        WHEN 3 THEN 'NTU'
    END
FROM dual
CONNECT BY LEVEL <= 200;

-- Verify the data
SELECT 'Employees' as table_name, COUNT(*) as count FROM employees
UNION ALL
SELECT 'IoT Devices', COUNT(*) FROM industrial_iot_data
UNION ALL
SELECT 'Maintenance Records', COUNT(*) FROM industrial_maintenance
UNION ALL
SELECT 'Performance Metrics', COUNT(*) FROM industrial_performance;

-- Sample data verification
SELECT department, COUNT(*) as employee_count
FROM employees
GROUP BY department
ORDER BY department;

SELECT device_type, COUNT(*) as device_count
FROM industrial_iot_data
GROUP BY device_type
ORDER BY device_type;

EXIT; 