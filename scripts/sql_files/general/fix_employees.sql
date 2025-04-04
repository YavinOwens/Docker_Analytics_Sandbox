-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- First, let's identify any missing employee IDs
SELECT 'workforce_attendance' as table_name, COUNT(DISTINCT employee_id) as total_employees,
       COUNT(DISTINCT CASE WHEN employee_id NOT IN (SELECT employee_id FROM employees) THEN employee_id END) as missing_employees
FROM workforce_attendance
UNION ALL
SELECT 'workforce_performance', COUNT(DISTINCT employee_id),
       COUNT(DISTINCT CASE WHEN employee_id NOT IN (SELECT employee_id FROM employees) THEN employee_id END)
FROM workforce_performance
UNION ALL
SELECT 'workforce_scheduling', COUNT(DISTINCT employee_id),
       COUNT(DISTINCT CASE WHEN employee_id NOT IN (SELECT employee_id FROM employees) THEN employee_id END)
FROM workforce_scheduling
UNION ALL
SELECT 'workforce_skills', COUNT(DISTINCT employee_id),
       COUNT(DISTINCT CASE WHEN employee_id NOT IN (SELECT employee_id FROM employees) THEN employee_id END)
FROM workforce_skills
UNION ALL
SELECT 'workforce_training', COUNT(DISTINCT employee_id),
       COUNT(DISTINCT CASE WHEN employee_id NOT IN (SELECT employee_id FROM employees) THEN employee_id END)
FROM workforce_training;

-- Insert missing employees from all workforce tables
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
    e.employee_id,
    SUBSTR(e.employee_id, 1, INSTR(e.employee_id, '_') - 1) as first_name,
    SUBSTR(e.employee_id, INSTR(e.employee_id, '_') + 1) as last_name,
    LOWER(SUBSTR(e.employee_id, 1, INSTR(e.employee_id, '_') - 1) || '.' || 
          SUBSTR(e.employee_id, INSTR(e.employee_id, '_') + 1) || '@company.com') as email,
    '555-' || LPAD(TO_CHAR(DBMS_RANDOM.VALUE(1000, 9999)), 4, '0') as phone,
    TO_DATE('2024-01-01', 'YYYY-MM-DD') + DBMS_RANDOM.VALUE(0, 365) as hire_date,
    CASE 
        WHEN e.employee_id LIKE '%_MGR%' THEN 'Management'
        WHEN e.employee_id LIKE '%_TECH%' THEN 'Technical'
        WHEN e.employee_id LIKE '%_ADMIN%' THEN 'Administrative'
        ELSE 'Operations'
    END as department,
    CASE 
        WHEN e.employee_id LIKE '%_MGR%' THEN 'Manager'
        WHEN e.employee_id LIKE '%_TECH%' THEN 'Technician'
        WHEN e.employee_id LIKE '%_ADMIN%' THEN 'Administrator'
        ELSE 'Operator'
    END as position,
    'ACTIVE' as status
FROM (
    SELECT DISTINCT employee_id FROM workforce_attendance
    UNION
    SELECT DISTINCT employee_id FROM workforce_performance
    UNION
    SELECT DISTINCT employee_id FROM workforce_scheduling
    UNION
    SELECT DISTINCT employee_id FROM workforce_skills
    UNION
    SELECT DISTINCT employee_id FROM workforce_training
) e
WHERE NOT EXISTS (
    SELECT 1 FROM employees emp WHERE emp.employee_id = e.employee_id
);

-- Now add the foreign key constraints
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

-- Verify the final state
SELECT COUNT(*) as total_employees,
       COUNT(DISTINCT department) as unique_departments,
       COUNT(DISTINCT position) as unique_positions,
       MIN(hire_date) as earliest_hire,
       MAX(hire_date) as latest_hire
FROM employees;

EXIT; 