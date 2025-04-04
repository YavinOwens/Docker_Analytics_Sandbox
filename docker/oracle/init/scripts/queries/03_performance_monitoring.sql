-- Performance Monitoring Queries

-- Session Information
SELECT
    s.sid,
    s.serial#,
    s.username,
    s.status,
    s.machine,
    s.program,
    s.event,
    s.wait_class
FROM
    v$session s
WHERE
    s.type != 'BACKGROUND'
ORDER BY
    s.status;

-- Active SQL Statements
SELECT
    s.sid,
    s.serial#,
    s.username,
    s.machine,
    q.sql_text,
    q.elapsed_time/1000000 as elapsed_seconds,
    q.cpu_time/1000000 as cpu_seconds
FROM
    v$session s
    JOIN v$sql q ON s.sql_id = q.sql_id
WHERE
    s.status = 'ACTIVE'
    AND s.type != 'BACKGROUND';

-- Table Space Usage
SELECT
    tablespace_name,
    bytes/1024/1024 as size_mb,
    (bytes-free_space)/1024/1024 as used_mb,
    free_space/1024/1024 as free_mb,
    ROUND((1-free_space/bytes)*100, 2) as used_pct
FROM
    (
        SELECT
            ts.tablespace_name,
            SUM(ts.bytes) bytes,
            NVL(SUM(fs.bytes), 0) free_space
        FROM
            dba_data_files ts,
            dba_free_space fs
        WHERE
            ts.tablespace_name = fs.tablespace_name (+)
        GROUP BY
            ts.tablespace_name
    );

-- Lock Information
SELECT
    l.session_id,
    s.serial#,
    s.username,
    l.lock_type,
    l.mode_held,
    l.mode_requested,
    l.lock_id1,
    l.lock_id2
FROM
    v$lock l
    JOIN v$session s ON l.session_id = s.sid
WHERE
    l.block = 1;
