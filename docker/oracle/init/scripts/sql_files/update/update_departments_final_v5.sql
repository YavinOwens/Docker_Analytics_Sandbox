-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Update departments and positions using a direct UPDATE
UPDATE employees
SET department = CASE 
    WHEN employee_id LIKE 'EMP_1%' THEN 'Executive Management'
    WHEN employee_id LIKE 'EMP_2%' THEN 'Senior Management'
    WHEN employee_id LIKE 'EMP_3%' THEN 'Department Management'
    WHEN employee_id LIKE 'EMP_4%' THEN 'Technical Operations'
    WHEN employee_id LIKE 'EMP_5%' THEN 'Engineering'
    WHEN employee_id LIKE 'EMP_6%' THEN 'Quality Assurance'
    WHEN employee_id LIKE 'EMP_7%' THEN 'Safety & Compliance'
    WHEN employee_id LIKE 'EMP_8%' THEN 'Information Technology'
    WHEN employee_id LIKE 'EMP_9%' THEN 'Human Resources'
    ELSE 'Operations'
END,
position = CASE 
    WHEN employee_id LIKE 'EMP_1%' THEN 'Senior Director'
    WHEN employee_id LIKE 'EMP_2%' THEN 'Senior Manager'
    WHEN employee_id LIKE 'EMP_3%' THEN 'Department Manager'
    WHEN employee_id LIKE 'EMP_4%' THEN 'Technician'
    WHEN employee_id LIKE 'EMP_5%' THEN 'Engineer'
    WHEN employee_id LIKE 'EMP_6%' THEN 'QA Specialist'
    WHEN employee_id LIKE 'EMP_7%' THEN 'Safety Officer'
    WHEN employee_id LIKE 'EMP_8%' THEN 'IT Specialist'
    WHEN employee_id LIKE 'EMP_9%' THEN 'HR Specialist'
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