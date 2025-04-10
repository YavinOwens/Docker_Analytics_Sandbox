-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREE

-- Set display format
SET LINESIZE 1000
SET PAGESIZE 1000

-- Drop existing tables
DROP TABLE water_utilities_assets CASCADE CONSTRAINTS;
DROP TABLE water_utilities_work_orders CASCADE CONSTRAINTS;
DROP TABLE ofwat_results CASCADE CONSTRAINTS;
DROP TABLE capex_projects CASCADE CONSTRAINTS;
DROP TABLE pulse_surveys CASCADE CONSTRAINTS;
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE performance_reviews CASCADE CONSTRAINTS;

-- Create tables with correct structure
CREATE TABLE water_utilities_assets (
    asset_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    asset_name VARCHAR2(200) NOT NULL,
    asset_type VARCHAR2(100) NOT NULL,
    location VARCHAR2(200),
    installation_date DATE,
    status VARCHAR2(50),
    last_maintenance_date DATE,
    next_maintenance_date DATE,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE water_utilities_work_orders (
    work_order_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    asset_id NUMBER REFERENCES water_utilities_assets(asset_id),
    work_order_type VARCHAR2(100) NOT NULL,
    priority VARCHAR2(50),
    status VARCHAR2(50),
    description VARCHAR2(1000),
    assigned_to VARCHAR2(200),
    created_date DATE,
    completed_date DATE,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE ofwat_results (
    result_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    quarter VARCHAR2(10),
    year NUMBER(4),
    quarter_number NUMBER(1),
    water_quality_score NUMBER(5,3),
    customer_service_score NUMBER(5,3),
    leakage_reduction_score NUMBER(5,3),
    water_efficiency_score NUMBER(5,3),
    environmental_impact_score NUMBER(5,3),
    operational_efficiency_score NUMBER(5,3),
    overall_performance_score NUMBER(5,3),
    performance_rating VARCHAR2(50),
    regulatory_compliance VARCHAR2(50),
    financial_incentives_earned NUMBER(15,2),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE capex_projects (
    project_id VARCHAR2(20) PRIMARY KEY,
    project_name VARCHAR2(200) NOT NULL,
    project_type VARCHAR2(100),
    start_date DATE,
    planned_end_date DATE,
    actual_end_date DATE,
    base_budget NUMBER(15,2),
    contingency_budget NUMBER(15,2),
    total_budget NUMBER(15,2),
    actual_cost NUMBER(15,2),
    progress_percentage NUMBER(5,2),
    status VARCHAR2(50),
    priority VARCHAR2(50),
    risk_level VARCHAR2(50),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE pulse_surveys (
    survey_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    survey_type VARCHAR2(100) NOT NULL,
    respondent_id VARCHAR2(100),
    response_date DATE,
    score NUMBER(5,2),
    comments VARCHAR2(1000),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE employees (
    employee_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR2(100) NOT NULL,
    last_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(200),
    department VARCHAR2(100),
    position VARCHAR2(100),
    hire_date DATE,
    status VARCHAR2(50),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE performance_reviews (
    review_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id NUMBER REFERENCES employees(employee_id),
    review_date DATE,
    reviewer_id NUMBER REFERENCES employees(employee_id),
    overall_rating NUMBER(3,1),
    comments VARCHAR2(2000),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_work_orders_asset ON water_utilities_work_orders(asset_id);
CREATE INDEX idx_ofwat_quarter ON ofwat_results(quarter, year);
CREATE INDEX idx_capex_status ON capex_projects(status);
CREATE INDEX idx_surveys_type ON pulse_surveys(survey_type);
CREATE INDEX idx_employees_dept ON employees(department);
CREATE INDEX idx_reviews_employee ON performance_reviews(employee_id);

-- Create triggers to update the updated_at timestamp
CREATE OR REPLACE TRIGGER trg_assets_upd
    BEFORE UPDATE ON water_utilities_assets
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_work_orders_upd
    BEFORE UPDATE ON water_utilities_work_orders
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_ofwat_upd
    BEFORE UPDATE ON ofwat_results
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_capex_upd
    BEFORE UPDATE ON capex_projects
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_surveys_upd
    BEFORE UPDATE ON pulse_surveys
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_employees_upd
    BEFORE UPDATE ON employees
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_reviews_upd
    BEFORE UPDATE ON performance_reviews
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Commit the changes
COMMIT;

-- Exit SQL*Plus
EXIT; 