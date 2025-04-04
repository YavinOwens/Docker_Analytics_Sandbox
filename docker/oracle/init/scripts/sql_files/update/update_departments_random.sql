-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Create a temporary table for department and position mapping
CREATE GLOBAL TEMPORARY TABLE dept_pos_mapping (
    department VARCHAR2(50),
    position VARCHAR2(100),
    weight NUMBER
) ON COMMIT PRESERVE ROWS;

-- Insert department and position combinations with weights
INSERT INTO dept_pos_mapping VALUES ('Executive Management', 'Senior Director', 1);
INSERT INTO dept_pos_mapping VALUES ('Senior Management', 'Senior Manager', 2);
INSERT INTO dept_pos_mapping VALUES ('Department Management', 'Department Manager', 5);
INSERT INTO dept_pos_mapping VALUES ('Technical Operations', 'Senior Technician', 10);
INSERT INTO dept_pos_mapping VALUES ('Technical Operations', 'Technical Lead', 15);
INSERT INTO dept_pos_mapping VALUES ('Technical Operations', 'Technician', 100);
INSERT INTO dept_pos_mapping VALUES ('Engineering', 'Senior Engineer', 5);
INSERT INTO dept_pos_mapping VALUES ('Engineering', 'Lead Engineer', 10);
INSERT INTO dept_pos_mapping VALUES ('Engineering', 'Engineer', 50);
INSERT INTO dept_pos_mapping VALUES ('Quality Assurance', 'Senior QA Specialist', 3);
INSERT INTO dept_pos_mapping VALUES ('Quality Assurance', 'QA Specialist', 20);
INSERT INTO dept_pos_mapping VALUES ('Safety & Compliance', 'Senior Safety Officer', 2);
INSERT INTO dept_pos_mapping VALUES ('Safety & Compliance', 'Safety Officer', 15);
INSERT INTO dept_pos_mapping VALUES ('Information Technology', 'Senior IT Specialist', 5);
INSERT INTO dept_pos_mapping VALUES ('Information Technology', 'IT Lead', 10);
INSERT INTO dept_pos_mapping VALUES ('Information Technology', 'IT Specialist', 30);
INSERT INTO dept_pos_mapping VALUES ('Human Resources', 'Senior HR Specialist', 3);
INSERT INTO dept_pos_mapping VALUES ('Human Resources', 'HR Specialist', 20);
INSERT INTO dept_pos_mapping VALUES ('Finance', 'Senior Financial Analyst', 5);
INSERT INTO dept_pos_mapping VALUES ('Finance', 'Financial Analyst', 25);
INSERT INTO dept_pos_mapping VALUES ('Customer Service', 'Senior Customer Service Representative', 5);
INSERT INTO dept_pos_mapping VALUES ('Customer Service', 'Customer Service Lead', 15);
INSERT INTO dept_pos_mapping VALUES ('Customer Service', 'Customer Service Representative', 50);
INSERT INTO dept_pos_mapping VALUES ('Administrative Services', 'Senior Administrator', 3);
INSERT INTO dept_pos_mapping VALUES ('Administrative Services', 'Administrative Assistant', 30);
INSERT INTO dept_pos_mapping VALUES ('Operations', 'Operations Specialist', 200);

-- Update employees with random department and position assignments
MERGE INTO employees e
USING (
    SELECT e.employee_id, 
           d.department,
           d.position
    FROM employees e
    CROSS JOIN (
        SELECT department, position
        FROM (
            SELECT department, position, weight,
                   SUM(weight) OVER (ORDER BY ROWNUM) as cum_weight
            FROM dept_pos_mapping
        )
        WHERE ROWNUM <= (SELECT COUNT(*) FROM employees)
    ) d
) new_assignments
ON (e.employee_id = new_assignments.employee_id)
WHEN MATCHED THEN
    UPDATE SET 
        e.department = new_assignments.department,
        e.position = new_assignments.position;

-- Drop temporary table
DROP TABLE dept_pos_mapping;

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