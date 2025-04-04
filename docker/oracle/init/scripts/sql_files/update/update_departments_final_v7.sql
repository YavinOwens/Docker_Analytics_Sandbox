WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK ON
SET LINESIZE 150
SET PAGESIZE 50

-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

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

COMMIT;

EXIT; 