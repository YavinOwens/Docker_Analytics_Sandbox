import pandas as pd
import os
import uuid

# Read the original CSV file
df = pd.read_csv('cleaned_data/industrial_data/water_utilities_work_orders.csv')

# Generate work order IDs if not present
if 'work_order_id' not in df.columns:
    df['work_order_id'] = [f'WO_{str(uuid.uuid4())[:8]}' for _ in range(len(df))]

# Convert dates to YYYY-MM-DD format
if 'creation_date' in df.columns:
    df['creation_date'] = pd.to_datetime(df['creation_date']).dt.strftime('%Y-%m-%d')
if 'completion_date' in df.columns:
    df['completion_date'] = pd.to_datetime(df['completion_date']).dt.strftime('%Y-%m-%d')

# Fill missing values and set default asset ID
df['asset_id'] = 'ASSET_DEFAULT'  # Set all work orders to use the default asset
df['type'] = df['type'].fillna('Maintenance')
df['priority'] = df['priority'].fillna(3)
df['status'] = df['status'].fillna('Open')
df['problem_description'] = df['problem_description'].fillna('No description provided')
df['assigned_technician'] = df['assigned_technician'].fillna('Unassigned')
df['required_certifications'] = df['required_certifications'].fillna('None')
df['estimated_hours'] = df['estimated_hours'].fillna(0)
df['actual_hours'] = df['actual_hours'].fillna(0)
df['parts_used'] = df['parts_used'].fillna('None')
df['downtime_hours'] = df['downtime_hours'].fillna(0)
df['safety_permits'] = df['safety_permits'].fillna('None')
df['completion_status'] = df['completion_status'].fillna('Pending')

# Truncate long text fields
df['parts_used'] = df['parts_used'].str.slice(0, 200)  # Limit to 200 characters
df['problem_description'] = df['problem_description'].str.slice(0, 500)  # Limit to 500 characters
df['required_certifications'] = df['required_certifications'].str.slice(0, 100)  # Limit to 100 characters
df['safety_permits'] = df['safety_permits'].str.slice(0, 100)  # Limit to 100 characters

# Ensure status values are valid
valid_statuses = ['Open', 'In Progress', 'Completed', 'Cancelled', 'On Hold', 'Assigned']
df['status'] = df['status'].apply(lambda x: x if x in valid_statuses else 'Open')

# Create output directory if it doesn't exist
os.makedirs('transformed_data/industrial_data', exist_ok=True)

# Save the transformed data
df.to_csv('transformed_data/industrial_data/water_utilities_work_orders.csv', index=False) 