CREATE TABLE water_utility_assets (
    asset_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    asset_type VARCHAR2(50) NOT NULL,
    location VARCHAR2(200) NOT NULL,
    status VARCHAR2(20) NOT NULL,
    installation_date DATE NOT NULL,
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    manufacturer VARCHAR2(100),
    model_number VARCHAR2(50),
    serial_number VARCHAR2(50),
    capacity NUMBER,
    unit_of_measure VARCHAR2(20),
    notes CLOB
);

FOREIGN KEY (asset_id) REFERENCES water_utility_assets(asset_id), 