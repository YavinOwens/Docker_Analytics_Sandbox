SET LINESIZE 1000
SET PAGESIZE 50

SELECT table_name 
FROM user_tables 
WHERE table_name LIKE '%WATER%' OR table_name LIKE '%EXT%'
ORDER BY table_name; 