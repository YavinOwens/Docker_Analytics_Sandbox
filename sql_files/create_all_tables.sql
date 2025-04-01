-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Drop existing tables
DROP TABLE water_utilities_work_orders CASCADE CONSTRAINTS;
DROP TABLE water_utilities_assets CASCADE CONSTRAINTS;
DROP TABLE ofwat_results CASCADE CONSTRAINTS;
DROP TABLE capex_projects CASCADE CONSTRAINTS;
DROP TABLE pulse_surveys CASCADE CONSTRAINTS;
DROP TABLE performance_reviews CASCADE CONSTRAINTS;
DROP TABLE leave_records CASCADE CONSTRAINTS;
DROP TABLE training_records CASCADE CONSTRAINTS;
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE advisor_data CASCADE CONSTRAINTS;
DROP TABLE trading_activity CASCADE CONSTRAINTS;
DROP TABLE interest_rates CASCADE CONSTRAINTS;
DROP TABLE sector_performance CASCADE CONSTRAINTS;
DROP TABLE market_indices CASCADE CONSTRAINTS;
DROP TABLE investment_products CASCADE CONSTRAINTS;
DROP TABLE client_portfolios CASCADE CONSTRAINTS;
DROP TABLE cash_flow CASCADE CONSTRAINTS;
DROP TABLE budgets CASCADE CONSTRAINTS;
DROP TABLE financial_statements CASCADE CONSTRAINTS;

-- Create tables with correct schemas
CREATE TABLE water_utilities_assets (
    asset_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    type VARCHAR2(50),
    category VARCHAR2(50),
    manufacturer VARCHAR2(100),
    model_number VARCHAR2(50),
    serial_number VARCHAR2(50),
    installation_date VARCHAR2(10),
    expected_lifetime_hours NUMBER,
    expected_lifetime_years NUMBER,
    purchase_cost NUMBER,
    replacement_cost NUMBER,
    warranty_expiration VARCHAR2(10),
    maintenance_interval NUMBER,
    standards CLOB,
    failure_modes CLOB,
    condition_score NUMBER,
    criticality_rating NUMBER,
    operational_status VARCHAR2(20),
    firmware_version VARCHAR2(20),
    parent_asset_id VARCHAR2(50),
    location CLOB,
    CONSTRAINT chk_asset_status CHECK (operational_status IN ('ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DECOMMISSIONED'))
);

CREATE TABLE water_utilities_work_orders (
    work_order_id VARCHAR2(50) PRIMARY KEY,
    asset_id VARCHAR2(50),
    type VARCHAR2(50),
    priority NUMBER,
    status VARCHAR2(20),
    problem_description CLOB,
    assigned_technician VARCHAR2(100),
    required_certifications CLOB,
    creation_date VARCHAR2(30),
    estimated_hours NUMBER,
    actual_hours NUMBER,
    parts_used CLOB,
    downtime_hours NUMBER,
    safety_permits CLOB,
    completion_status VARCHAR2(20),
    completion_date VARCHAR2(30),
    FOREIGN KEY (asset_id) REFERENCES water_utilities_assets(asset_id),
    CONSTRAINT chk_work_order_status CHECK (status IN ('Open', 'In Progress', 'Completed', 'Cancelled', 'On Hold', 'Assigned'))
);

CREATE TABLE ofwat_results (
    quarter VARCHAR2(10),
    year NUMBER,
    quarter_number NUMBER,
    water_quality_score NUMBER,
    customer_service_score NUMBER,
    leakage_reduction_score NUMBER,
    water_efficiency_score NUMBER,
    environmental_impact_score NUMBER,
    operational_efficiency_score NUMBER,
    overall_performance_score NUMBER,
    performance_rating VARCHAR2(50),
    key_achievements CLOB,
    areas_for_improvement CLOB,
    regulatory_compliance VARCHAR2(20),
    financial_incentives_earned NUMBER,
    CONSTRAINT pk_ofwat_results PRIMARY KEY (year, quarter_number),
    CONSTRAINT chk_ofwat_rating CHECK (performance_rating IN ('Good', 'Poor', 'Requires Improvement', 'Outstanding'))
);

CREATE TABLE capex_projects (
    project_id VARCHAR2(20) PRIMARY KEY,
    project_name VARCHAR2(100),
    project_type VARCHAR2(50),
    start_date VARCHAR2(10),
    planned_end_date VARCHAR2(10),
    actual_end_date VARCHAR2(10),
    base_budget NUMBER,
    contingency_budget NUMBER,
    total_budget NUMBER,
    actual_cost NUMBER,
    progress_percentage NUMBER,
    status VARCHAR2(20),
    priority VARCHAR2(20),
    risk_level VARCHAR2(20),
    benefits_realized CLOB,
    key_milestones CLOB,
    stakeholders CLOB,
    CONSTRAINT chk_capex_status CHECK (status IN ('In Progress', 'Completed', 'On Hold', 'Cancelled', 'Delayed')),
    CONSTRAINT chk_capex_priority CHECK (priority IN ('High', 'Medium', 'Low')),
    CONSTRAINT chk_capex_risk CHECK (risk_level IN ('High', 'Medium', 'Low'))
);

CREATE TABLE pulse_surveys (
    survey_id VARCHAR2(20) PRIMARY KEY,
    survey_date VARCHAR2(10),
    department VARCHAR2(50),
    response_rate NUMBER,
    engagement_score NUMBER,
    satisfaction_score NUMBER,
    wellbeing_score NUMBER,
    culture_score NUMBER,
    leadership_score NUMBER,
    development_score NUMBER,
    work_life_balance_score NUMBER,
    recognition_score NUMBER,
    overall_score NUMBER,
    key_findings CLOB,
    action_items CLOB,
    employee_feedback CLOB,
    CONSTRAINT chk_survey_scores CHECK (
        engagement_score BETWEEN 0 AND 1 AND
        satisfaction_score BETWEEN 0 AND 1 AND
        wellbeing_score BETWEEN 0 AND 1 AND
        culture_score BETWEEN 0 AND 1 AND
        leadership_score BETWEEN 0 AND 1 AND
        development_score BETWEEN 0 AND 1 AND
        work_life_balance_score BETWEEN 0 AND 1 AND
        recognition_score BETWEEN 0 AND 1 AND
        overall_score BETWEEN 0 AND 1
    )
);

CREATE TABLE employees (
    employee_id VARCHAR2(20) PRIMARY KEY,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    email VARCHAR2(100),
    phone VARCHAR2(20),
    department VARCHAR2(50),
    role VARCHAR2(50),
    hire_date VARCHAR2(10),
    employment_status VARCHAR2(20),
    salary NUMBER,
    bonus_target NUMBER,
    certifications CLOB,
    skills CLOB,
    location CLOB,
    manager_id VARCHAR2(20),
    emergency_contact CLOB,
    CONSTRAINT chk_employee_status CHECK (employment_status IN ('Active', 'Inactive', 'On Leave', 'Terminated')),
    CONSTRAINT chk_employee_department CHECK (department IN ('Operations', 'Maintenance', 'Quality Control', 'Safety', 'Logistics', 'Training', 'HR', 'Management'))
);

CREATE TABLE performance_reviews (
    review_id VARCHAR2(20) PRIMARY KEY,
    employee_id VARCHAR2(20),
    review_date VARCHAR2(10),
    reviewer_id VARCHAR2(20),
    overall_rating NUMBER,
    technical_skills NUMBER,
    communication NUMBER,
    leadership NUMBER,
    safety_compliance NUMBER,
    attendance NUMBER,
    bonus_awarded NUMBER(1),
    bonus_amount NUMBER,
    comments CLOB,
    goals_set CLOB,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (reviewer_id) REFERENCES employees(employee_id),
    CONSTRAINT chk_review_ratings CHECK (
        overall_rating BETWEEN 1 AND 5 AND
        technical_skills BETWEEN 1 AND 5 AND
        communication BETWEEN 1 AND 5 AND
        leadership BETWEEN 1 AND 5 AND
        safety_compliance BETWEEN 1 AND 5 AND
        attendance BETWEEN 1 AND 5
    )
);

CREATE TABLE leave_records (
    leave_id VARCHAR2(20) PRIMARY KEY,
    employee_id VARCHAR2(20),
    leave_type VARCHAR2(50),
    start_date VARCHAR2(10),
    end_date VARCHAR2(10),
    status VARCHAR2(20),
    reason VARCHAR2(100),
    approved_by VARCHAR2(20),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id),
    CONSTRAINT chk_leave_status CHECK (status IN ('Pending', 'Approved', 'Rejected', 'Cancelled')),
    CONSTRAINT chk_leave_type CHECK (leave_type IN ('Sick Leave', 'Vacation', 'Personal Leave', 'Family Leave', 'Emergency Leave'))
);

CREATE TABLE training_records (
    training_id VARCHAR2(20) PRIMARY KEY,
    employee_id VARCHAR2(20),
    training_type VARCHAR2(50),
    provider VARCHAR2(100),
    start_date VARCHAR2(10),
    end_date VARCHAR2(10),
    status VARCHAR2(20),
    score NUMBER,
    certification_earned NUMBER(1),
    cost NUMBER,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT chk_training_status CHECK (status IN ('Scheduled', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT chk_training_score CHECK (score BETWEEN 0 AND 100)
);

CREATE TABLE advisor_data (
    advisor_id VARCHAR2(50) PRIMARY KEY,
    name VARCHAR2(100),
    client_count NUMBER,
    total_aum NUMBER,
    start_date VARCHAR2(10),
    client_retention_rate NUMBER,
    client_satisfaction_score NUMBER,
    new_client_acquisition NUMBER
);

CREATE TABLE trading_activity (
    transaction_id VARCHAR2(50) PRIMARY KEY,
    transaction_date VARCHAR2(30),
    client_id VARCHAR2(50),
    product_id VARCHAR2(50),
    transaction_type VARCHAR2(20),
    share_quantity NUMBER,
    price_per_share NUMBER,
    total_value NUMBER,
    fee_amount NUMBER
);

CREATE TABLE interest_rates (
    transaction_date VARCHAR2(10) PRIMARY KEY,
    rate_type VARCHAR2(50),
    rate_value NUMBER,
    effective_date VARCHAR2(10),
    maturity_date VARCHAR2(10),
    currency VARCHAR2(3)
);

CREATE TABLE sector_performance (
    sector_id VARCHAR2(50) PRIMARY KEY,
    sector_name VARCHAR2(100),
    transaction_date VARCHAR2(10),
    performance_score NUMBER,
    market_cap NUMBER,
    volume NUMBER,
    volatility NUMBER
);

CREATE TABLE market_indices (
    index_id VARCHAR2(50) PRIMARY KEY,
    index_name VARCHAR2(100),
    transaction_date VARCHAR2(10),
    value NUMBER,
    change_percentage NUMBER,
    volume NUMBER
);

CREATE TABLE investment_products (
    product_id VARCHAR2(50) PRIMARY KEY,
    product_name VARCHAR2(100),
    product_type VARCHAR2(50),
    risk_level VARCHAR2(20),
    min_investment NUMBER,
    management_fee NUMBER,
    performance_fee NUMBER,
    inception_date VARCHAR2(10),
    status VARCHAR2(20),
    CONSTRAINT chk_product_status CHECK (status IN ('Active', 'Inactive', 'Suspended', 'Closed'))
);

CREATE TABLE client_portfolios (
    portfolio_id VARCHAR2(50) PRIMARY KEY,
    client_id VARCHAR2(50),
    product_id VARCHAR2(50),
    transaction_date VARCHAR2(10),
    quantity NUMBER,
    value NUMBER,
    FOREIGN KEY (product_id) REFERENCES investment_products(product_id)
);

CREATE TABLE cash_flow (
    transaction_id VARCHAR2(50) PRIMARY KEY,
    transaction_date VARCHAR2(10),
    category VARCHAR2(50),
    amount NUMBER,
    description VARCHAR2(200),
    status VARCHAR2(20),
    CONSTRAINT chk_cash_flow_status CHECK (status IN ('Pending', 'Completed', 'Failed', 'Cancelled'))
);

CREATE TABLE budgets (
    budget_id VARCHAR2(50) PRIMARY KEY,
    department VARCHAR2(50),
    fiscal_year NUMBER,
    allocated_amount NUMBER,
    spent_amount NUMBER,
    remaining_amount NUMBER,
    status VARCHAR2(20),
    CONSTRAINT chk_budget_status CHECK (status IN ('Active', 'Closed', 'Over Budget', 'Under Review'))
);

CREATE TABLE financial_statements (
    statement_id VARCHAR2(50) PRIMARY KEY,
    statement_type VARCHAR2(50),
    transaction_date VARCHAR2(10),
    period VARCHAR2(20),
    revenue NUMBER,
    expenses NUMBER,
    net_income NUMBER,
    assets NUMBER,
    liabilities NUMBER,
    equity NUMBER,
    CONSTRAINT chk_statement_type CHECK (statement_type IN ('Income Statement', 'Balance Sheet', 'Cash Flow Statement'))
);

-- Create indexes for better performance
CREATE INDEX idx_work_orders_asset_id ON water_utilities_work_orders(asset_id);
CREATE INDEX idx_performance_reviews_employee_id ON performance_reviews(employee_id);
CREATE INDEX idx_leave_records_employee_id ON leave_records(employee_id);
CREATE INDEX idx_training_records_employee_id ON training_records(employee_id);
CREATE INDEX idx_client_portfolios_product_id ON client_portfolios(product_id);

COMMIT;

-- Exit SQL*Plus
EXIT; 