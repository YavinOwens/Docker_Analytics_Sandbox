-- Industrial IoT Data Table
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

-- Industrial Maintenance Table
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
    FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id)
);

-- Industrial Performance Table
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

-- Industrial Safety Table
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
    FOREIGN KEY (device_id) REFERENCES industrial_iot_data(device_id)
); 