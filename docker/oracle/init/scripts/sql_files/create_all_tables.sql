-- Create all tables for app_user schema
SET ECHO ON
SET FEEDBACK ON
SET LINESIZE 1000
SET PAGESIZE 1000
SET SERVEROUTPUT ON
SET VERIFY OFF

PROMPT Starting cleanup of existing tables...

-- Drop existing tables if they exist
BEGIN
   FOR t IN (SELECT table_name FROM user_tables) LOOP
      EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
   END LOOP;
END;
/

PROMPT Starting table creation...

WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Create tables in order of dependencies
PROMPT Creating interest rates table...
@/tmp/sql_files/create/create_interest_rates.sql

PROMPT Creating financial tables...
CREATE TABLE financial_statements (
    statement_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    statement_date DATE NOT NULL,
    statement_type VARCHAR2(50) NOT NULL,
    revenue NUMBER(15,2),
    expenses NUMBER(15,2),
    net_income NUMBER(15,2),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE budgets (
    budget_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fiscal_year NUMBER(4) NOT NULL,
    department VARCHAR2(100) NOT NULL,
    allocated_amount NUMBER(15,2) NOT NULL,
    spent_amount NUMBER(15,2) DEFAULT 0,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE cash_flow (
    flow_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR2(50) NOT NULL,
    amount NUMBER(15,2) NOT NULL,
    category VARCHAR2(100),
    description VARCHAR2(500),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

PROMPT Creating sector performance table...
@/tmp/sql_files/create/create_sector_performance.sql

PROMPT Creating trading activity table...
@/tmp/sql_files/create/create_trading_activity.sql

PROMPT Creating industrial tables...
@/tmp/sql_files/create/create_industrial_tables.sql

PROMPT Creating employee tables...
-- Create the master employees table
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

-- Create employee salary table
CREATE TABLE employee_salary (
    salary_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    salary_amount NUMBER(15,2),
    effective_date DATE,
    end_date DATE,
    salary_type VARCHAR2(20),
    currency VARCHAR2(3),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Create employee benefits table
CREATE TABLE employee_benefits (
    benefit_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    benefit_type VARCHAR2(50),
    benefit_description VARCHAR2(500),
    start_date DATE,
    end_date DATE,
    status VARCHAR2(20),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Create employee attendance table
CREATE TABLE employee_attendance (
    attendance_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    attendance_date DATE,
    check_in TIMESTAMP,
    check_out TIMESTAMP,
    status VARCHAR2(20),
    notes VARCHAR2(500),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Create employee performance table
CREATE TABLE employee_performance (
    performance_id VARCHAR2(50) PRIMARY KEY,
    employee_id VARCHAR2(50),
    review_date DATE,
    reviewer_id VARCHAR2(50),
    rating NUMBER(2,1),
    comments VARCHAR2(1000),
    goals_achieved VARCHAR2(1000),
    improvement_areas VARCHAR2(1000),
    next_review_date DATE,
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (reviewer_id) REFERENCES employees(employee_id)
);

PROMPT Creating water utilities tables...
@/tmp/sql_files/create/docker_create_water_utilities_tables.sql

PROMPT Creating water utilities calculations...
@/tmp/sql_files/create/docker_create_water_utilities_calculations.sql

PROMPT Creating compliance reports...
@/tmp/sql_files/create/docker_create_compliance_reports.sql

PROMPT Creating workforce tables...
@/tmp/sql_files/create/create_workforce_tables.sql

PROMPT Creating reporting views...
@/tmp/sql_files/create/create_reporting_views.sql

PROMPT Verifying created tables...
SELECT table_name, owner
FROM all_tables
WHERE owner = 'APP_USER'
ORDER BY table_name;

PROMPT Table creation completed.
