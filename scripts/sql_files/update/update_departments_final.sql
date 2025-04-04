-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Create a temporary table for department and position mapping
CREATE GLOBAL TEMPORARY TABLE dept_pos_mapping (
    department VARCHAR2(50),
    position VARCHAR2(100)
) ON COMMIT PRESERVE ROWS;

-- Insert department and position combinations
INSERT INTO dept_pos_mapping VALUES ('Executive Management', 'Senior Director');
INSERT INTO dept_pos_mapping VALUES ('Senior Management', 'Senior Manager');
INSERT INTO dept_pos_mapping VALUES ('Department Management', 'Department Manager');
INSERT INTO dept_pos_mapping VALUES ('Technical Operations', 'Technician');
INSERT INTO dept_pos_mapping VALUES ('Engineering', 'Engineer');
INSERT INTO dept_pos_mapping VALUES ('Quality Assurance', 'QA Specialist');
INSERT INTO dept_pos_mapping VALUES ('Safety & Compliance', 'Safety Officer');
INSERT INTO dept_pos_mapping VALUES ('Information Technology', 'IT Specialist');
INSERT INTO dept_pos_mapping VALUES ('Human Resources', 'HR Specialist');
INSERT INTO dept_pos_mapping VALUES ('Operations', 'Operations Specialist');

-- Update employees with department and position assignments
UPDATE employees e
SET (department, position) = (
    SELECT department, position
    FROM (
        SELECT department, position, ROWNUM as rn
        FROM dept_pos_mapping
    )
    WHERE rn = MOD(ROWNUM, 10) + 1
);

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