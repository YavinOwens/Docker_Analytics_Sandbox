-- 1. Test connection and show instance information
SELECT
    instance_name,
    host_name,
    version,
    status,
    startup_time,
    database_status
FROM
    v$instance;

-- 2. Show database configuration
SELECT
    name,
    value,
    description
FROM
    v$parameter
WHERE
    name IN ('db_name', 'db_unique_name', 'service_names', 'compatible');

-- 3. Create a test table
CREATE TABLE connection_test (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    test_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    test_value VARCHAR2(100),
    CONSTRAINT connection_test_pk PRIMARY KEY (id)
);

-- 4. Insert test data
INSERT INTO connection_test (test_value) VALUES ('Test connection successful');
COMMIT;

-- 5. Query the test data
SELECT
    id,
    test_timestamp,
    test_value
FROM
    connection_test
ORDER BY
    id;

-- 6. Show user privileges
SELECT
    username,
    account_status,
    default_tablespace,
    created
FROM
    dba_users
WHERE
    username NOT IN ('SYS', 'SYSTEM')
ORDER BY
    created DESC;

-- 7. Show available tablespaces
SELECT
    tablespace_name,
    status,
    contents,
    logging
FROM
    dba_tablespaces
ORDER BY
    tablespace_name;

-- 8. Clean up test table
DROP TABLE connection_test PURGE;
