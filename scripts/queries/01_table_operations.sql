-- Table Operations Template
-- Replace placeholders with actual values

-- Create new table
CREATE TABLE ${table_name} (
    id NUMBER GENERATED ALWAYS AS IDENTITY,
    created_date DATE DEFAULT SYSDATE,
    modified_date DATE,
    status VARCHAR2(20) DEFAULT 'ACTIVE',
    CONSTRAINT ${table_name}_pk PRIMARY KEY (id)
);

-- Add columns
ALTER TABLE ${table_name} ADD (
    new_column1 VARCHAR2(100),
    new_column2 NUMBER
);

-- Add constraints
ALTER TABLE ${table_name} ADD CONSTRAINT ${constraint_name}
    CHECK (status IN ('ACTIVE', 'INACTIVE', 'DELETED'));

-- Create index
CREATE INDEX ${index_name} ON ${table_name}(column_name);

-- Add foreign key
ALTER TABLE ${table_name} ADD CONSTRAINT ${fk_name}
    FOREIGN KEY (column_name) REFERENCES other_table(id);

-- Create sequence
CREATE SEQUENCE ${sequence_name}
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
