SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 200
SET PAGESIZE 1000
SET SERVEROUTPUT ON

-- Disable foreign key constraints
BEGIN
  FOR c IN (SELECT constraint_name, table_name FROM user_constraints WHERE constraint_type = 'R') LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || ' DISABLE CONSTRAINT ' || c.constraint_name;
  END LOOP;
END;
/

-- Drop existing tables if they exist
DROP TABLE industrial_safety CASCADE CONSTRAINTS;
DROP TABLE industrial_maintenance CASCADE CONSTRAINTS;
DROP TABLE industrial_iot_data CASCADE CONSTRAINTS;

-- Create industrial_iot_data table
CREATE TABLE industrial_iot_data (
    device_id VARCHAR2(50) PRIMARY KEY,
    device_name VARCHAR2(100),
    device_type VARCHAR2(50),
    location VARCHAR2(50),
    status VARCHAR2(20),
    last_reading NUMBER,
    reading_timestamp TIMESTAMP,
    battery_level NUMBER,
    signal_strength NUMBER
);

-- Create industrial_maintenance table
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
    CONSTRAINT fk_maintenance_device FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id)
);

-- Create industrial_safety table
CREATE TABLE industrial_safety (
    safety_id VARCHAR2(50) PRIMARY KEY,
    device_id VARCHAR2(50),
    incident_type VARCHAR2(50),
    incident_date DATE,
    severity_level VARCHAR2(20),
    description VARCHAR2(500),
    action_taken VARCHAR2(500),
    reported_by VARCHAR2(100),
    status VARCHAR2(20),
    CONSTRAINT fk_safety_device FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id)
);

-- Re-enable foreign key constraints
BEGIN
  FOR c IN (SELECT constraint_name, table_name FROM user_constraints WHERE constraint_type = 'R') LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || ' ENABLE CONSTRAINT ' || c.constraint_name;
  END LOOP;
END;
/

-- Verify tables were created
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN ('INDUSTRIAL_IOT_DATA', 'INDUSTRIAL_MAINTENANCE', 'INDUSTRIAL_SAFETY');

EXIT; 