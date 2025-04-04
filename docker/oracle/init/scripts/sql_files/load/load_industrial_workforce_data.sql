-- Load Industrial IoT Data
SET DEFINE OFF;
SET FEEDBACK OFF;
SET VERIFY OFF;

-- Industrial IoT Data
@load_industrial_iot_data.sql

-- Industrial Maintenance
@load_industrial_maintenance.sql

-- Industrial Performance
@load_industrial_performance.sql

-- Industrial Safety
@load_industrial_safety.sql

-- Workforce Attendance
@load_workforce_attendance.sql

-- Workforce Performance
@load_workforce_performance.sql

-- Workforce Skills
@load_workforce_skills.sql

-- Workforce Training
@load_workforce_training.sql

-- Workforce Scheduling
@load_workforce_scheduling.sql

-- Workforce Leave
@load_workforce_leave.sql

-- Verify data loading
SELECT 'Industrial IoT Data' as table_name, COUNT(*) as row_count FROM industrial_iot_data UNION ALL
SELECT 'Industrial Maintenance', COUNT(*) FROM industrial_maintenance UNION ALL
SELECT 'Industrial Performance', COUNT(*) FROM industrial_performance UNION ALL
SELECT 'Industrial Safety', COUNT(*) FROM industrial_safety UNION ALL
SELECT 'Workforce Attendance', COUNT(*) FROM workforce_attendance UNION ALL
SELECT 'Workforce Performance', COUNT(*) FROM workforce_performance UNION ALL
SELECT 'Workforce Skills', COUNT(*) FROM workforce_skills UNION ALL
SELECT 'Workforce Training', COUNT(*) FROM workforce_training UNION ALL
SELECT 'Workforce Scheduling', COUNT(*) FROM workforce_scheduling UNION ALL
SELECT 'Workforce Leave', COUNT(*) FROM workforce_leave;

COMMIT; 