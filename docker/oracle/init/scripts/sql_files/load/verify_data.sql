SET PAGESIZE 1000
SET LINESIZE 1000
SET FEEDBACK OFF
SET VERIFY OFF

PROMPT Checking INDUSTRIAL_IOT_DATA table:
SELECT device_id, device_name, device_type, status 
FROM industrial_iot_data 
WHERE ROWNUM <= 3;

PROMPT
PROMPT Checking INDUSTRIAL_MAINTENANCE table:
SELECT maintenance_id, device_id, maintenance_type, status 
FROM industrial_maintenance 
WHERE ROWNUM <= 3;

PROMPT
PROMPT Checking INDUSTRIAL_SAFETY table:
SELECT safety_id, device_id, incident_type, severity_level 
FROM industrial_safety 
WHERE ROWNUM <= 3; 