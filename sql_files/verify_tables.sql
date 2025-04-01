-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREE

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Check Financial Statements data
SELECT * FROM financial_statements ORDER BY statement_date;

-- Check Budgets data
SELECT * FROM budgets ORDER BY fiscal_year;

-- Check Cash Flow data
SELECT * FROM cash_flow ORDER BY transaction_date;

-- Exit SQL*Plus
EXIT; 