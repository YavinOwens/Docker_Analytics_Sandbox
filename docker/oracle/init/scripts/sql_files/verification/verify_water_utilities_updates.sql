-- Connect to the database
CONNECT app_user/Welcome123@//localhost:1521/FREEPDB1

-- Set display format for better readability
SET LINESIZE 150
SET PAGESIZE 50

-- 1. Check Employees Table
SELECT '=== Employees Table ===' as section FROM dual;
SELECT department, position, COUNT(*) as count
FROM employees
GROUP BY department, position
ORDER BY department, position;

-- 2. Check Industrial IoT Data
SELECT '=== Industrial IoT Data ===' as section FROM dual;
SELECT device_type, location, COUNT(*) as count
FROM industrial_iot_data
GROUP BY device_type, location
ORDER BY device_type, location;

-- 3. Check Industrial Maintenance
SELECT '=== Industrial Maintenance ===' as section FROM dual;
SELECT maintenance_type, COUNT(*) as count
FROM industrial_maintenance
GROUP BY maintenance_type
ORDER BY maintenance_type;

-- 4. Check Industrial Performance
SELECT '=== Industrial Performance ===' as section FROM dual;
SELECT metric_name, unit, COUNT(*) as count
FROM industrial_performance
GROUP BY metric_name, unit
ORDER BY metric_name, unit;

-- 5. Check Industrial Safety
SELECT '=== Industrial Safety ===' as section FROM dual;
SELECT incident_type, severity_level, COUNT(*) as count
FROM industrial_safety
GROUP BY incident_type, severity_level
ORDER BY incident_type, severity_level;

-- 6. Check Workforce Attendance
SELECT '=== Workforce Attendance ===' as section FROM dual;
SELECT notes, COUNT(*) as count
FROM workforce_attendance
GROUP BY notes
ORDER BY notes;

-- 7. Check Workforce Skills
SELECT '=== Workforce Skills ===' as section FROM dual;
SELECT skill_name, proficiency_level, COUNT(*) as count
FROM workforce_skills
GROUP BY skill_name, proficiency_level
ORDER BY skill_name, proficiency_level;

-- 8. Check Workforce Training
SELECT '=== Workforce Training ===' as section FROM dual;
SELECT training_name, training_type, COUNT(*) as count
FROM workforce_training
GROUP BY training_name, training_type
ORDER BY training_name, training_type;

-- 9. Check Workforce Scheduling
SELECT '=== Workforce Scheduling ===' as section FROM dual;
SELECT shift_type, COUNT(*) as count
FROM workforce_scheduling
GROUP BY shift_type
ORDER BY shift_type;

-- 10. Sample Data Verification
SELECT '=== Sample Data Verification ===' as section FROM dual;

-- Sample employee records
SELECT 'Sample Employee Records:' as message FROM dual;
SELECT employee_id, first_name, last_name, department, position, email
FROM employees
WHERE ROWNUM <= 5
ORDER BY employee_id;

-- Sample IoT device records
SELECT 'Sample IoT Device Records:' as message FROM dual;
SELECT device_id, device_name, device_type, location, status
FROM industrial_iot_data
WHERE ROWNUM <= 5
ORDER BY device_id;

-- Sample maintenance records
SELECT 'Sample Maintenance Records:' as message FROM dual;
SELECT maintenance_id, device_id, maintenance_type, status
FROM industrial_maintenance
WHERE ROWNUM <= 5
ORDER BY maintenance_id;

EXIT; 