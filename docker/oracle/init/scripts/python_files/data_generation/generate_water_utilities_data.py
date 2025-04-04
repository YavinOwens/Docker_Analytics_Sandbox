import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import uuid
import os

print("Starting script execution...")

# Create output directory if it doesn't exist
output_dir = 'transformed_data/water_utilities_data'
print(f"Creating directory: {output_dir}")
os.makedirs(output_dir, exist_ok=True)

def generate_water_utility_assets(num_assets=100):
    print(f"Generating {num_assets} water utilities assets...")
    asset_types = ['Pump', 'Valve', 'Filter', 'Tank', 'Meter', 'Sensor', 'Treatment Plant']
    locations = ['North Zone', 'South Zone', 'East Zone', 'West Zone', 'Central Zone']
    statuses = ['ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DECOMMISSIONED']
    
    # Generate random dates
    base_date = datetime.now()
    installation_dates = [base_date - timedelta(days=np.random.randint(0, 3650)) for _ in range(num_assets)]
    last_maintenance_dates = [date + timedelta(days=np.random.randint(0, 365)) for date in installation_dates]
    next_maintenance_dates = [date + timedelta(days=np.random.randint(30, 365)) for date in last_maintenance_dates]
    
    data = {
        'asset_id': [f'ASSET_{str(uuid.uuid4())[:8]}' for _ in range(num_assets)],
        'asset_name': [f'Asset_{i+1}' for i in range(num_assets)],
        'asset_type': np.random.choice(asset_types, num_assets),
        'location': np.random.choice(locations, num_assets),
        'installation_date': [date.strftime('%Y-%m-%d') for date in installation_dates],
        'status': np.random.choice(statuses, num_assets),
        'last_maintenance_date': [date.strftime('%Y-%m-%d') for date in last_maintenance_dates],
        'next_maintenance_date': [date.strftime('%Y-%m-%d') for date in next_maintenance_dates],
        'manufacturer': [f'Manufacturer_{np.random.randint(1, 6)}' for _ in range(num_assets)],
        'model_number': [f'MODEL_{np.random.randint(1000, 9999)}' for _ in range(num_assets)],
        'serial_number': [f'SERIAL_{str(uuid.uuid4())[:8]}' for _ in range(num_assets)],
        'expected_lifetime_hours': np.random.randint(10000, 50000, num_assets),
        'expected_lifetime_years': np.random.randint(5, 30, num_assets),
        'purchase_cost': np.random.randint(1000, 100000, num_assets),
        'replacement_cost': np.random.randint(1000, 100000, num_assets),
        'warranty_expiration': [(base_date + timedelta(days=np.random.randint(365, 3650))).strftime('%Y-%m-%d') for _ in range(num_assets)],
        'maintenance_interval': np.random.randint(30, 365, num_assets),
        'condition_score': np.random.randint(1, 100, num_assets),
        'criticality_rating': np.random.randint(1, 5, num_assets),
        'firmware_version': [f'v{np.random.randint(1, 5)}.{np.random.randint(0, 10)}.{np.random.randint(0, 10)}' for _ in range(num_assets)]
    }
    
    print("Creating DataFrame...")
    df = pd.DataFrame(data)
    
    # Add CLOB fields with sample data
    print("Adding CLOB fields...")
    df['standards'] = 'ISO 9001:2015, ISO 14001:2015'
    df['failure_modes'] = 'Mechanical failure, Electrical failure, Corrosion'
    df['location'] = df['location'].apply(lambda x: f'{{"zone": "{x}", "coordinates": {{"lat": {np.random.uniform(-90, 90)}, "lon": {np.random.uniform(-180, 180)}}}}}')
    
    return df

if __name__ == "__main__":
    try:
        # Generate and save water utilities assets data
        print("Starting data generation...")
        assets_df = generate_water_utility_assets()
        
        output_file = 'transformed_data/water_utilities_data/water_utility_assets.csv'
        print(f"Saving data to: {output_file}")
        assets_df.to_csv(output_file, index=False)
        print("Water utilities assets data generated successfully!")
    except Exception as e:
        print(f"Error occurred: {str(e)}") 