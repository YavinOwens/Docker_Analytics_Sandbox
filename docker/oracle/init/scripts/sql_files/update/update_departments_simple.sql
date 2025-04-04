-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Update departments and positions with a simpler approach
UPDATE employees
SET department = CASE 
    WHEN MOD(ROWNUM, 10) = 1 THEN 'Executive Management'
    WHEN MOD(ROWNUM, 10) = 2 THEN 'Senior Management'
    WHEN MOD(ROWNUM, 10) = 3 THEN 'Department Management'
    WHEN MOD(ROWNUM, 10) = 4 THEN 'Technical Operations'
    WHEN MOD(ROWNUM, 10) = 5 THEN 'Engineering'
    WHEN MOD(ROWNUM, 10) = 6 THEN 'Quality Assurance'
    WHEN MOD(ROWNUM, 10) = 7 THEN 'Safety & Compliance'
    WHEN MOD(ROWNUM, 10) = 8 THEN 'Information Technology'
    WHEN MOD(ROWNUM, 10) = 9 THEN 'Human Resources'
    ELSE 'Operations'
END,
position = CASE 
    WHEN MOD(ROWNUM, 10) = 1 THEN 'Senior Director'
    WHEN MOD(ROWNUM, 10) = 2 THEN 'Senior Manager'
    WHEN MOD(ROWNUM, 10) = 3 THEN 'Department Manager'
    WHEN MOD(ROWNUM, 10) = 4 THEN 'Technician'
    WHEN MOD(ROWNUM, 10) = 5 THEN 'Engineer'
    WHEN MOD(ROWNUM, 10) = 6 THEN 'QA Specialist'
    WHEN MOD(ROWNUM, 10) = 7 THEN 'Safety Officer'
    WHEN MOD(ROWNUM, 10) = 8 THEN 'IT Specialist'
    WHEN MOD(ROWNUM, 10) = 9 THEN 'HR Specialist'
    ELSE 'Operations Specialist'
END;

-- Verify the updated structure
SELECT department, position, COUNT(*) as employee_count
FROM employees
GROUP BY department, position
ORDER BY department, position;

-- Show department distribution
SELECT department, COUNT(*) as total_employees,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees), 2) as percentage
FROM employees
GROUP BY department
ORDER BY total_employees DESC;

EXIT; 