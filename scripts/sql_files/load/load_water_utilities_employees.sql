-- Connect to the database
CONNECT app_user/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Create a sequence for generating employee IDs
CREATE SEQUENCE emp_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Insert water utilities employee data
INSERT INTO employees (
    employee_id,
    first_name,
    last_name,
    email,
    phone,
    hire_date,
    department,
    position,
    status
) VALUES 
    ('WU001', 'John', 'Smith', 'john.smith@waterutilities.com', '555-1001', TO_DATE('2023-01-15', 'YYYY-MM-DD'), 'Water Treatment', 'Plant Manager', 'ACTIVE'),
    ('WU002', 'Sarah', 'Johnson', 'sarah.johnson@waterutilities.com', '555-1002', TO_DATE('2023-02-01', 'YYYY-MM-DD'), 'Water Treatment', 'Senior Operator', 'ACTIVE'),
    ('WU003', 'Michael', 'Brown', 'michael.brown@waterutilities.com', '555-1003', TO_DATE('2023-03-10', 'YYYY-MM-DD'), 'Distribution', 'Network Manager', 'ACTIVE'),
    ('WU004', 'Emily', 'Davis', 'emily.davis@waterutilities.com', '555-1004', TO_DATE('2023-04-05', 'YYYY-MM-DD'), 'Distribution', 'Field Technician', 'ACTIVE'),
    ('WU005', 'David', 'Wilson', 'david.wilson@waterutilities.com', '555-1005', TO_DATE('2023-05-20', 'YYYY-MM-DD'), 'Quality Control', 'Lab Manager', 'ACTIVE'),
    ('WU006', 'Lisa', 'Anderson', 'lisa.anderson@waterutilities.com', '555-1006', TO_DATE('2023-06-15', 'YYYY-MM-DD'), 'Quality Control', 'Water Quality Analyst', 'ACTIVE'),
    ('WU007', 'Robert', 'Taylor', 'robert.taylor@waterutilities.com', '555-1007', TO_DATE('2023-07-01', 'YYYY-MM-DD'), 'Customer Service', 'Service Manager', 'ACTIVE'),
    ('WU008', 'Jennifer', 'Martinez', 'jennifer.martinez@waterutilities.com', '555-1008', TO_DATE('2023-08-10', 'YYYY-MM-DD'), 'Customer Service', 'Customer Service Representative', 'ACTIVE'),
    ('WU009', 'William', 'Lee', 'william.lee@waterutilities.com', '555-1009', TO_DATE('2023-09-05', 'YYYY-MM-DD'), 'Maintenance', 'Maintenance Supervisor', 'ACTIVE'),
    ('WU010', 'Amanda', 'White', 'amanda.white@waterutilities.com', '555-1010', TO_DATE('2023-10-15', 'YYYY-MM-DD'), 'Maintenance', 'Maintenance Technician', 'ACTIVE');

-- Insert additional employees for water treatment operations
INSERT INTO employees (
    employee_id,
    first_name,
    last_name,
    email,
    phone,
    hire_date,
    department,
    position,
    status
) VALUES 
    ('WU011', 'Thomas', 'Clark', 'thomas.clark@waterutilities.com', '555-1011', TO_DATE('2023-11-01', 'YYYY-MM-DD'), 'Water Treatment', 'Operator', 'ACTIVE'),
    ('WU012', 'Michelle', 'Rodriguez', 'michelle.rodriguez@waterutilities.com', '555-1012', TO_DATE('2023-12-10', 'YYYY-MM-DD'), 'Water Treatment', 'Operator', 'ACTIVE'),
    ('WU013', 'Daniel', 'Moore', 'daniel.moore@waterutilities.com', '555-1013', TO_DATE('2024-01-05', 'YYYY-MM-DD'), 'Distribution', 'Field Technician', 'ACTIVE'),
    ('WU014', 'Jessica', 'Thompson', 'jessica.thompson@waterutilities.com', '555-1014', TO_DATE('2024-02-15', 'YYYY-MM-DD'), 'Distribution', 'Field Technician', 'ACTIVE'),
    ('WU015', 'Christopher', 'Garcia', 'christopher.garcia@waterutilities.com', '555-1015', TO_DATE('2024-03-01', 'YYYY-MM-DD'), 'Quality Control', 'Water Quality Analyst', 'ACTIVE');

-- Insert management team
INSERT INTO employees (
    employee_id,
    first_name,
    last_name,
    email,
    phone,
    hire_date,
    department,
    position,
    status
) VALUES 
    ('WU016', 'Richard', 'Martin', 'richard.martin@waterutilities.com', '555-1016', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'Executive', 'Operations Director', 'ACTIVE'),
    ('WU017', 'Patricia', 'Thompson', 'patricia.thompson@waterutilities.com', '555-1017', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'Executive', 'Quality Assurance Manager', 'ACTIVE'),
    ('WU018', 'Joseph', 'Anderson', 'joseph.anderson@waterutilities.com', '555-1018', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'Executive', 'Customer Service Director', 'ACTIVE');

-- Verify the data
SELECT 
    department,
    COUNT(*) as employee_count,
    LISTAGG(first_name || ' ' || last_name, ', ') WITHIN GROUP (ORDER BY last_name) as employees
FROM employees
GROUP BY department
ORDER BY department;

-- Display employee details
SELECT 
    employee_id,
    first_name || ' ' || last_name as full_name,
    department,
    position,
    hire_date,
    status
FROM employees
ORDER BY department, last_name;

EXIT; 