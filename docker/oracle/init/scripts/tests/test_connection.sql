-- Test database connection and show basic information
SELECT
    instance_name,
    host_name,
    version,
    startup_time
FROM
    v$instance;

-- Show available tables
SELECT
    owner,
    table_name,
    tablespace_name,
    status
FROM
    all_tables
WHERE
    owner NOT IN ('SYS', 'SYSTEM')
ORDER BY
    owner, table_name;
