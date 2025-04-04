-- Connect to the database
CONNECT app_user/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- First, let's see what departments we currently have
SELECT DISTINCT department FROM employees ORDER BY department;

-- Update departments to water utilities specific departments
UPDATE employees 
SET department = CASE 
    WHEN department LIKE '%MANAGEMENT%' THEN 'Executive'
    WHEN department LIKE '%TECHNICAL%' THEN 'Water Treatment'
    WHEN department LIKE '%ADMIN%' THEN 'Customer Service'
    ELSE 'Distribution'
END;

-- Update positions to water utilities specific positions
UPDATE employees 
SET position = CASE 
    WHEN position LIKE '%MANAGER%' THEN 'Plant Manager'
    WHEN position LIKE '%TECH%' THEN 'Field Technician'
    WHEN position LIKE '%ADMIN%' THEN 'Customer Service Representative'
    ELSE 'Operator'
END;

-- Update email domains to water utilities domain
UPDATE employees 
SET email = REPLACE(email, '@company.com', '@waterutilities.com');

-- Update phone numbers to water utilities format
UPDATE employees 
SET phone = '555-' || LPAD(TO_CHAR(DBMS_RANDOM.VALUE(1000, 9999)), 4, '0');

-- Verify the updates
SELECT 
    department,
    COUNT(*) as employee_count,
    LISTAGG(first_name || ' ' || last_name, ', ') WITHIN GROUP (ORDER BY last_name) as employees
FROM employees
GROUP BY department
ORDER BY department;

-- Display updated employee details
SELECT 
    employee_id,
    first_name || ' ' || last_name as full_name,
    department,
    position,
    email,
    phone,
    hire_date,
    status
FROM employees
ORDER BY department, last_name;

-- Update workforce tables to reflect new departments
UPDATE workforce_attendance 
SET department = (
    SELECT department 
    FROM employees 
    WHERE employees.employee_id = workforce_attendance.employee_id
);

UPDATE workforce_performance 
SET department = (
    SELECT department 
    FROM employees 
    WHERE employees.employee_id = workforce_performance.employee_id
);

UPDATE workforce_scheduling 
SET department = (
    SELECT department 
    FROM employees 
    WHERE employees.employee_id = workforce_scheduling.employee_id
);

UPDATE workforce_skills 
SET department = (
    SELECT department 
    FROM employees 
    WHERE employees.employee_id = workforce_skills.employee_id
);

UPDATE workforce_training 
SET department = (
    SELECT department 
    FROM employees 
    WHERE employees.employee_id = workforce_training.employee_id
);

-- Verify workforce table updates
SELECT 
    department,
    COUNT(*) as employee_count
FROM workforce_attendance
GROUP BY department
ORDER BY department;

EXIT; 