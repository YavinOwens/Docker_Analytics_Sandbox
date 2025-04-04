-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 100
SET PAGESIZE 50

-- Create Financial Statements table
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

-- Create Budgets table
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

-- Create Cash Flow table
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

-- Create indexes for better performance
CREATE INDEX idx_financial_statements_date ON financial_statements(statement_date);
CREATE INDEX idx_budgets_fiscal_year ON budgets(fiscal_year);
CREATE INDEX idx_cash_flow_date ON cash_flow(transaction_date);

-- Create triggers to update the updated_at timestamp
CREATE OR REPLACE TRIGGER trg_financial_statements_upd
    BEFORE UPDATE ON financial_statements
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_budgets_upd
    BEFORE UPDATE ON budgets
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

CREATE OR REPLACE TRIGGER trg_cash_flow_upd
    BEFORE UPDATE ON cash_flow
    FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Insert some sample data
INSERT INTO financial_statements (statement_date, statement_type, revenue, expenses, net_income)
VALUES (SYSDATE, 'MONTHLY', 1000000.00, 750000.00, 250000.00);

INSERT INTO budgets (fiscal_year, department, allocated_amount)
VALUES (2024, 'IT', 500000.00);

INSERT INTO cash_flow (transaction_date, transaction_type, amount, category, description)
VALUES (SYSDATE, 'INCOME', 100000.00, 'SALES', 'Monthly sales revenue');

-- Commit the changes
COMMIT;

-- Verify the tables were created
SELECT table_name, num_rows 
FROM user_tables 
WHERE table_name IN ('FINANCIAL_STATEMENTS', 'BUDGETS', 'CASH_FLOW');

-- Show table structures
DESC financial_statements;
DESC budgets;
DESC cash_flow;

-- Exit SQL*Plus
EXIT; 