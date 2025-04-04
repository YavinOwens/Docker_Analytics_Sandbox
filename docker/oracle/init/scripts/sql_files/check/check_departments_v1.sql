WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK ON
SET LINESIZE 150
SET PAGESIZE 50
SET SERVEROUTPUT ON

-- Connect to the database
CONNECT system/Welcome123@//localhost:1521/FREEPDB1

-- Show current department and position distribution
SELECT department, position, COUNT(*) as employee_count
FROM employees
GROUP BY department, position
ORDER BY department, position;

-- Show department distribution with percentages
SELECT department, COUNT(*) as total_employees,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM employees), 2) as percentage
FROM employees
GROUP BY department
ORDER BY total_employees DESC;

EXIT; 