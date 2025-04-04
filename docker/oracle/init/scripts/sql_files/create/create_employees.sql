-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- Drop existing table if it exists
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE employees CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;
/

-- Create the master employees table
CREATE TABLE employees (
    employee_id VARCHAR2(50) PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE NOT NULL,
    phone VARCHAR2(20),
    hire_date DATE NOT NULL,
    department VARCHAR2(50),
    position VARCHAR2(100),
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    updated_at TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT chk_emp_status CHECK (status IN ('ACTIVE', 'INACTIVE', 'ON_LEAVE', 'TERMINATED'))
);

-- Create index on email
CREATE INDEX idx_emp_email ON employees(email);

-- Create index on department
CREATE INDEX idx_emp_dept ON employees(department);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE TRIGGER trg_emp_updated_at
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    :NEW.updated_at := SYSTIMESTAMP;
END;
/

-- Extract unique employee information from workforce tables
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
)
SELECT DISTINCT
    wa.employee_id,
    SUBSTR(wa.employee_id, 1, INSTR(wa.employee_id, '_') - 1) as first_name,
    SUBSTR(wa.employee_id, INSTR(wa.employee_id, '_') + 1) as last_name,
    LOWER(SUBSTR(wa.employee_id, 1, INSTR(wa.employee_id, '_') - 1) || '.' || 
          SUBSTR(wa.employee_id, INSTR(wa.employee_id, '_') + 1) || '@company.com') as email,
    '555-' || LPAD(TO_CHAR(DBMS_RANDOM.VALUE(1000, 9999)), 4, '0') as phone,
    TO_DATE('2024-01-01', 'YYYY-MM-DD') + DBMS_RANDOM.VALUE(0, 365) as hire_date,
    CASE 
        WHEN wa.employee_id LIKE '%_MGR%' THEN 'Management'
        WHEN wa.employee_id LIKE '%_TECH%' THEN 'Technical'
        WHEN wa.employee_id LIKE '%_ADMIN%' THEN 'Administrative'
        ELSE 'Operations'
    END as department,
    CASE 
        WHEN wa.employee_id LIKE '%_MGR%' THEN 'Manager'
        WHEN wa.employee_id LIKE '%_TECH%' THEN 'Technician'
        WHEN wa.employee_id LIKE '%_ADMIN%' THEN 'Administrator'
        ELSE 'Operator'
    END as position,
    'ACTIVE' as status
FROM workforce_attendance wa
WHERE NOT EXISTS (
    SELECT 1 FROM employees e WHERE e.employee_id = wa.employee_id
);

-- Add foreign key constraints to workforce tables
ALTER TABLE workforce_attendance
ADD CONSTRAINT fk_wa_employee
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id);

ALTER TABLE workforce_performance
ADD CONSTRAINT fk_wp_employee
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id);

ALTER TABLE workforce_scheduling
ADD CONSTRAINT fk_ws_employee
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id);

ALTER TABLE workforce_skills
ADD CONSTRAINT fk_wsk_employee
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id);

ALTER TABLE workforce_training
ADD CONSTRAINT fk_wt_employee
FOREIGN KEY (employee_id)
REFERENCES employees(employee_id);

-- Verify the data
SELECT COUNT(*) as total_employees,
       COUNT(DISTINCT department) as unique_departments,
       COUNT(DISTINCT position) as unique_positions,
       MIN(hire_date) as earliest_hire,
       MAX(hire_date) as latest_hire
FROM employees;

EXIT; 