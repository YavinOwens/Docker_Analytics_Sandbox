SET LINESIZE 200
SET PAGESIZE 50
SELECT COUNT(*) as total_orders,
       COUNT(DISTINCT asset_id) as unique_assets,
       MIN(creation_date) as earliest_date,
       MAX(creation_date) as latest_date,
       COUNT(CASE WHEN completion_date IS NOT NULL THEN 1 END) as completed_orders
FROM water_utilities_work_orders; 