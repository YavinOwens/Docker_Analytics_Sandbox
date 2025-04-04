-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Create a temporary table for department and position mapping
CREATE GLOBAL TEMPORARY TABLE dept_pos_mapping (
    dept_name VARCHAR2(50),
    pos_name VARCHAR2(50),
    start_row NUMBER,
    end_row NUMBER
) ON COMMIT PRESERVE ROWS;

-- Insert department and position mappings
INSERT INTO dept_pos_mapping VALUES ('Executive Management', 'Senior Director', 1, 10);
INSERT INTO dept_pos_mapping VALUES ('Senior Management', 'Senior Manager', 11, 30);
INSERT INTO dept_pos_mapping VALUES ('Department Management', 'Department Manager', 31, 100);
INSERT INTO dept_pos_mapping VALUES ('Technical Operations', 'Technician', 101, 500);
INSERT INTO dept_pos_mapping VALUES ('Engineering', 'Engineer', 501, 800);
INSERT INTO dept_pos_mapping VALUES ('Quality Assurance', 'QA Specialist', 801, 1000);
INSERT INTO dept_pos_mapping VALUES ('Safety & Compliance', 'Safety Officer', 1001, 1200);
INSERT INTO dept_pos_mapping VALUES ('Information Technology', 'IT Specialist', 1201, 1500);
INSERT INTO dept_pos_mapping VALUES ('Human Resources', 'HR Specialist', 1501, 1800);
INSERT INTO dept_pos_mapping VALUES ('Operations', 'Operations Specialist', 1801, 999999);

-- Update employees table using the mapping
UPDATE employees e
SET (department, position) = (
    SELECT dept_name, pos_name
    FROM dept_pos_mapping m
    WHERE ROWNUM BETWEEN m.start_row AND m.end_row
    AND ROWNUM = e.employee_id
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

-- Drop the temporary table
DROP TABLE dept_pos_mapping;

EXIT; 