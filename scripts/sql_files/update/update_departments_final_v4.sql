-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Update departments and positions using row numbers
UPDATE employees e
SET (department, position) = (
    SELECT CASE 
        WHEN rn <= 10 THEN 'Executive Management'
        WHEN rn <= 30 THEN 'Senior Management'
        WHEN rn <= 100 THEN 'Department Management'
        WHEN rn <= 500 THEN 'Technical Operations'
        WHEN rn <= 800 THEN 'Engineering'
        WHEN rn <= 1000 THEN 'Quality Assurance'
        WHEN rn <= 1200 THEN 'Safety & Compliance'
        WHEN rn <= 1500 THEN 'Information Technology'
        WHEN rn <= 1800 THEN 'Human Resources'
        ELSE 'Operations'
    END,
    CASE 
        WHEN rn <= 10 THEN 'Senior Director'
        WHEN rn <= 30 THEN 'Senior Manager'
        WHEN rn <= 100 THEN 'Department Manager'
        WHEN rn <= 500 THEN 'Technician'
        WHEN rn <= 800 THEN 'Engineer'
        WHEN rn <= 1000 THEN 'QA Specialist'
        WHEN rn <= 1200 THEN 'Safety Officer'
        WHEN rn <= 1500 THEN 'IT Specialist'
        WHEN rn <= 1800 THEN 'HR Specialist'
        ELSE 'Operations Specialist'
    END
    FROM (
        SELECT employee_id, ROWNUM as rn
        FROM employees
    ) t
    WHERE t.employee_id = e.employee_id
);

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