-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Update departments and positions with a more comprehensive structure
UPDATE employees
SET department = CASE 
    WHEN employee_id LIKE '%_MGR%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SENIOR%' THEN 'Executive Management'
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Management'
            ELSE 'Department Management'
        END
    WHEN employee_id LIKE '%_TECH%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Technical'
            WHEN employee_id LIKE '%_LEAD%' THEN 'Technical Leadership'
            ELSE 'Technical Operations'
        END
    WHEN employee_id LIKE '%_ADMIN%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Administration'
            ELSE 'Administrative Services'
        END
    WHEN employee_id LIKE '%_ENG%' THEN 'Engineering'
    WHEN employee_id LIKE '%_QA%' THEN 'Quality Assurance'
    WHEN employee_id LIKE '%_SAFETY%' THEN 'Safety & Compliance'
    WHEN employee_id LIKE '%_IT%' THEN 'Information Technology'
    WHEN employee_id LIKE '%_HR%' THEN 'Human Resources'
    WHEN employee_id LIKE '%_FIN%' THEN 'Finance'
    WHEN employee_id LIKE '%_CUST%' THEN 'Customer Service'
    ELSE 'Operations'
END,
position = CASE 
    WHEN employee_id LIKE '%_MGR%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SENIOR%' THEN 'Senior Director'
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Manager'
            ELSE 'Department Manager'
        END
    WHEN employee_id LIKE '%_TECH%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Technician'
            WHEN employee_id LIKE '%_LEAD%' THEN 'Technical Lead'
            ELSE 'Technician'
        END
    WHEN employee_id LIKE '%_ADMIN%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Administrator'
            ELSE 'Administrative Assistant'
        END
    WHEN employee_id LIKE '%_ENG%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Engineer'
            WHEN employee_id LIKE '%_LEAD%' THEN 'Lead Engineer'
            ELSE 'Engineer'
        END
    WHEN employee_id LIKE '%_QA%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior QA Specialist'
            ELSE 'QA Specialist'
        END
    WHEN employee_id LIKE '%_SAFETY%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Safety Officer'
            ELSE 'Safety Officer'
        END
    WHEN employee_id LIKE '%_IT%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior IT Specialist'
            WHEN employee_id LIKE '%_LEAD%' THEN 'IT Lead'
            ELSE 'IT Specialist'
        END
    WHEN employee_id LIKE '%_HR%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior HR Specialist'
            ELSE 'HR Specialist'
        END
    WHEN employee_id LIKE '%_FIN%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Financial Analyst'
            ELSE 'Financial Analyst'
        END
    WHEN employee_id LIKE '%_CUST%' THEN 
        CASE 
            WHEN employee_id LIKE '%_SR%' THEN 'Senior Customer Service Representative'
            WHEN employee_id LIKE '%_LEAD%' THEN 'Customer Service Lead'
            ELSE 'Customer Service Representative'
        END
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