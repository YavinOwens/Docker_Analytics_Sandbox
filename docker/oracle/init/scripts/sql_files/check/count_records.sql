SET LINESIZE 1000
SET PAGESIZE 50

SELECT 'INDUSTRIAL_IOT_DATA: ' || COUNT(*) as COUNT FROM INDUSTRIAL_IOT_DATA;
SELECT 'INDUSTRIAL_MAINTENANCE: ' || COUNT(*) as COUNT FROM INDUSTRIAL_MAINTENANCE;
SELECT 'INDUSTRIAL_SAFETY: ' || COUNT(*) as COUNT FROM INDUSTRIAL_SAFETY;
SELECT 'WATER_UTILITY_ASSETS: ' || COUNT(*) as COUNT FROM WATER_UTILITY_ASSETS;
SELECT 'WATER_UTILITIES_WORK_ORDERS: ' || COUNT(*) as COUNT FROM WATER_UTILITIES_WORK_ORDERS;
SELECT 'OFWAT_RESULTS: ' || COUNT(*) as COUNT FROM OFWAT_RESULTS; 