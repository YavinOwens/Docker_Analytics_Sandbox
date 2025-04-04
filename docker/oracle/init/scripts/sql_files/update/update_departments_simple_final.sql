-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Update departments and positions with a simple approach
UPDATE employees
SET department = CASE 
    WHEN ROWNUM <= 10 THEN 'Executive Management'
    WHEN ROWNUM <= 30 THEN 'Senior Management'
    WHEN ROWNUM <= 100 THEN 'Department Management'
    WHEN ROWNUM <= 500 THEN 'Technical Operations'
    WHEN ROWNUM <= 800 THEN 'Engineering'
    WHEN ROWNUM <= 1000 THEN 'Quality Assurance'
    WHEN ROWNUM <= 1200 THEN 'Safety & Compliance'
    WHEN ROWNUM <= 1500 THEN 'Information Technology'
    WHEN ROWNUM <= 1800 THEN 'Human Resources'
    ELSE 'Operations'
END,
position = CASE 
    WHEN ROWNUM <= 10 THEN 'Senior Director'
    WHEN ROWNUM <= 30 THEN 'Senior Manager'
    WHEN ROWNUM <= 100 THEN 'Department Manager'
    WHEN ROWNUM <= 500 THEN 'Technician'
    WHEN ROWNUM <= 800 THEN 'Engineer'
    WHEN ROWNUM <= 1000 THEN 'QA Specialist'
    WHEN ROWNUM <= 1200 THEN 'Safety Officer'
    WHEN ROWNUM <= 1500 THEN 'IT Specialist'
    WHEN ROWNUM <= 1800 THEN 'HR Specialist'
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