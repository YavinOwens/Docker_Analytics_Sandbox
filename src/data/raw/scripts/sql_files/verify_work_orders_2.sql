SET LINESIZE 200
SET PAGESIZE 50
SELECT type, COUNT(*) as count
FROM water_utilities_work_orders
GROUP BY type
ORDER BY count DESC;

SELECT status, COUNT(*) as count
FROM water_utilities_work_orders
GROUP BY status
ORDER BY count DESC; 