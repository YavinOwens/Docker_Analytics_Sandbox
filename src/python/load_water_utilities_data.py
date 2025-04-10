import cx_Oracle
import pandas as pd
from datetime import datetime

# Connect to the database
connection = cx_Oracle.connect('system/Welcome123@//localhost:1521/FREEPDB1')
cursor = connection.cursor()

try:
    # Create directory for data loading
    cursor.execute("CREATE OR REPLACE DIRECTORY data_dir AS '/opt/oracle/data'")
    cursor.execute("GRANT READ ON DIRECTORY data_dir TO PUBLIC")
    
    # Drop table if it exists
    try:
        cursor.execute("DROP TABLE water_utility_assets CASCADE CONSTRAINTS")
    except cx_Oracle.DatabaseError as e:
        if e.args[0].code != 942:  # ORA-00942: table or view does not exist
            raise
    
    # Create table
    cursor.execute("""
    CREATE TABLE water_utility_assets (
        asset_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        asset_type VARCHAR2(50) NOT NULL,
        location VARCHAR2(200) NOT NULL,
        status VARCHAR2(20) NOT NULL,
        installation_date DATE NOT NULL,
        last_maintenance_date DATE,
        next_maintenance_date DATE,
        manufacturer VARCHAR2(100),
        model_number VARCHAR2(50),
        serial_number VARCHAR2(50),
        capacity NUMBER,
        unit_of_measure VARCHAR2(20),
        notes CLOB
    )
    """)
    
    # Read CSV file
    df = pd.read_csv('transformed_data/water_utilities_data/water_utility_assets.csv')
    
    # Convert date columns
    date_columns = ['installation_date', 'last_maintenance_date', 'next_maintenance_date']
    for col in date_columns:
        df[col] = pd.to_datetime(df[col])
    
    # Prepare data for insertion
    for _, row in df.iterrows():
        cursor.execute("""
        INSERT INTO water_utility_assets (
            asset_type,
            location,
            status,
            installation_date,
            last_maintenance_date,
            next_maintenance_date,
            manufacturer,
            model_number,
            serial_number,
            capacity,
            unit_of_measure,
            notes
        ) VALUES (
            :1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12
        )
        """, (
            row['asset_type'],
            row['location'],
            row['status'],
            row['installation_date'],
            row['last_maintenance_date'],
            row['next_maintenance_date'],
            row['manufacturer'],
            row['model_number'],
            row['serial_number'],
            row['capacity'],
            row['unit_of_measure'],
            row['notes']
        ))
    
    # Commit the changes
    connection.commit()
    
    # Verify data loading
    cursor.execute("""
    SELECT COUNT(*) as total_assets,
           COUNT(DISTINCT asset_type) as unique_asset_types,
           MIN(installation_date) as earliest_installation,
           MAX(installation_date) as latest_installation
    FROM water_utility_assets
    """)
    result = cursor.fetchone()
    print(f"Total assets: {result[0]}")
    print(f"Unique asset types: {result[1]}")
    print(f"Earliest installation: {result[2]}")
    print(f"Latest installation: {result[3]}")

finally:
    cursor.close()
    connection.close() 