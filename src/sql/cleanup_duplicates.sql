-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREE

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Start a transaction
SET TRANSACTION NAME 'cleanup_duplicates';

-- Clean up Financial Statements table
-- Keep only the most recent entry
DELETE FROM financial_statements 
WHERE statement_id < (
    SELECT MAX(statement_id) 
    FROM financial_statements
);

-- Clean up Budgets table
-- Keep only the most recent entry
DELETE FROM budgets 
WHERE budget_id < (
    SELECT MAX(budget_id) 
    FROM budgets
);

-- Clean up Cash Flow table
-- Keep only the most recent entry
DELETE FROM cash_flow 
WHERE flow_id < (
    SELECT MAX(flow_id) 
    FROM cash_flow
);

-- Commit the changes
COMMIT;

-- Verify the cleanup
SELECT 'Financial Statements' as table_name, COUNT(*) as row_count FROM financial_statements
UNION ALL
SELECT 'Budgets' as table_name, COUNT(*) as row_count FROM budgets
UNION ALL
SELECT 'Cash Flow' as table_name, COUNT(*) as row_count FROM cash_flow;

-- Show the remaining data
SELECT * FROM financial_statements ORDER BY statement_date;
SELECT * FROM budgets ORDER BY fiscal_year;
SELECT * FROM cash_flow ORDER BY transaction_date;

-- Exit SQL*Plus
EXIT; 