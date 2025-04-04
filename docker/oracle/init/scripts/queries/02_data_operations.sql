-- Data Operations Template

-- Basic SELECT
SELECT * FROM table_name
WHERE condition = 'value'
ORDER BY column_name;

-- INSERT with SELECT
INSERT INTO target_table (column1, column2)
SELECT column1, column2
FROM source_table
WHERE condition = 'value';

-- UPDATE with JOIN
UPDATE table1 t1
SET t1.column1 = t2.column1
FROM table1 t1
JOIN table2 t2 ON t1.id = t2.id
WHERE t2.condition = 'value';

-- MERGE statement
MERGE INTO target_table t
USING source_table s
ON (t.id = s.id)
WHEN MATCHED THEN
    UPDATE SET
        t.column1 = s.column1,
        t.column2 = s.column2
WHEN NOT MATCHED THEN
    INSERT (id, column1, column2)
    VALUES (s.id, s.column1, s.column2);

-- Bulk DELETE
DELETE FROM table_name
WHERE condition IN (
    SELECT id
    FROM other_table
    WHERE status = 'INACTIVE'
);
