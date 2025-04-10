import pandas as pd
import numpy as np
from faker import Faker
from datetime import datetime, timedelta
import random
import yaml
from pathlib import Path
import uuid
import json
from scipy import stats
import os

# Set random seeds for reproducibility
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)
fake = Faker()
Faker.seed(RANDOM_SEED)

class IndustrialIoTGenerator:
    def __init__(self):
        self.start_date = datetime(2019, 1, 1)
        self.end_date = datetime.now()
        self.config = self._load_config()
        
        # Create output directory
        self.output_dir = Path('industrial_data')
        self.output_dir.mkdir(exist_ok=True)
        
        # Initialize counters
        self.asset_counter = 0
        self.work_order_counter = 0
        
    def _load_config(self):
        """Load configuration from YAML file"""
        with open('industry_config.yaml', 'r') as f:
            return yaml.safe_load(f)
    
    def generate_asset_master_data(self, sector):
        """Generate asset master data for a specific sector"""
        assets = []
        sector_config = self.config['sectors'][sector]
        
        for category, asset_types in sector_config['asset_types'].items():
            for asset_type in asset_types:
                # Generate multiple instances of each asset type
                num_instances = random.randint(50, 200)  # 50-200 instances per type
                
                for _ in range(num_instances):
                    self.asset_counter += 1
                    asset_id = f"{sector[:2].upper()}-{category[:2].upper()}-{self.asset_counter:06d}"
                    
                    # Generate asset data
                    asset = {
                        'asset_id': asset_id,
                        'name': f"{asset_type['name']} #{self.asset_counter:03d}",
                        'type': asset_type['name'],
                        'category': category,
                        'manufacturer': fake.company(),
                        'model_number': f"MOD-{fake.bothify('??###')}",
                        'serial_number': fake.uuid4(),
                        'installation_date': fake.date_between(
                            start_date='-10y',
                            end_date='-1y'
                        ),
                        'expected_lifetime_hours': random.randint(40000, 100000),
                        'expected_lifetime_years': random.randint(10, 25),
                        'purchase_cost': random.uniform(10000, 1000000),
                        'replacement_cost': random.uniform(15000, 1500000),
                        'warranty_expiration': fake.date_between(
                            start_date='+1y',
                            end_date='+5y'
                        ),
                        'maintenance_interval': asset_type['maintenance_interval'],
                        'standards': asset_type['standards'],
                        'failure_modes': asset_type['failure_modes'],
                        'condition_score': random.uniform(60, 100),
                        'criticality_rating': random.randint(1, 5),
                        'operational_status': random.choice([
                            'Running', 'Standby', 'Maintenance', 'Failed'
                        ]),
                        'firmware_version': f"{random.randint(1,5)}.{random.randint(0,9)}.{random.randint(0,9)}",
                        'parent_asset_id': None,  # Will be updated later
                        'location': self._generate_location(sector)
                    }
                    
                    assets.append(asset)
        
        # Establish parent-child relationships
        for asset in assets:
            if random.random() < 0.3:  # 30% chance of having a parent
                potential_parents = [
                    a for a in assets 
                    if a['asset_id'] != asset['asset_id'] and 
                    a['category'] == asset['category']
                ]
                if potential_parents:
                    asset['parent_asset_id'] = random.choice(potential_parents)['asset_id']
        
        df = pd.DataFrame(assets)
        df.to_csv(self.output_dir / f'{sector}_assets.csv', index=False)
        return df
    
    def _generate_location(self, sector):
        """Generate location data for an asset"""
        facilities = self.config['locations']['facilities'][sector]
        facility = random.choice(facilities)
        area = random.choice(facility['areas'])
        
        return {
            'facility_name': facility['name'],
            'area': area,
            'location_code': f"{facility['name'][:3].upper()}-{area[:3].upper()}",
            'lat': facility['lat'] + random.uniform(-0.01, 0.01),
            'lon': facility['lon'] + random.uniform(-0.01, 0.01)
        }
    
    def generate_work_orders(self, sector, assets_df):
        """Generate work order history"""
        work_orders = []
        
        # Generate work orders for each asset
        for _, asset in assets_df.iterrows():
            # Calculate number of work orders based on asset age and maintenance interval
            installation_date = pd.to_datetime(asset['installation_date'])
            days_since_installation = (self.end_date - installation_date).days
            expected_work_orders = days_since_installation / (asset['maintenance_interval'] / 24)
            
            num_work_orders = int(np.random.poisson(expected_work_orders))
            
            for _ in range(num_work_orders):
                self.work_order_counter += 1
                work_order_id = f"WO-{sector[:2].upper()}-{self.work_order_counter:06d}"
                
                # Generate work order data
                work_order = {
                    'work_order_id': work_order_id,
                    'asset_id': asset['asset_id'],
                    'type': random.choice(self.config['maintenance_types']),
                    'priority': random.randint(1, 5),
                    'status': random.choice(self.config['work_order_status']),
                    'problem_description': random.choice(asset['failure_modes']),
                    'assigned_technician': fake.name(),
                    'required_certifications': random.sample(
                        self.config['compliance_standards'],
                        k=random.randint(1, 3)
                    ),
                    'creation_date': fake.date_time_between(
                        start_date=installation_date,
                        end_date=self.end_date
                    ),
                    'estimated_hours': random.uniform(2, 48),
                    'actual_hours': None,  # Will be updated based on status
                    'parts_used': self._generate_parts_used(),
                    'downtime_hours': None,  # Will be updated based on status
                    'safety_permits': random.sample(
                        self.config['safety_requirements']['permits'],
                        k=random.randint(1, 3)
                    ),
                    'completion_status': None  # Will be updated based on status
                }
                
                # Update fields based on status
                if work_order['status'] in ['Completed', 'Cancelled']:
                    completion_date = fake.date_time_between(
                        start_date=work_order['creation_date'],
                        end_date=min(
                            work_order['creation_date'] + timedelta(days=30),
                            self.end_date
                        )
                    )
                    work_order['completion_date'] = completion_date
                    work_order['actual_hours'] = work_order['estimated_hours'] * random.uniform(0.8, 1.2)
                    work_order['downtime_hours'] = work_order['actual_hours'] * random.uniform(1.0, 1.5)
                    work_order['completion_status'] = 'Success' if random.random() < 0.9 else 'Partial'
                
                work_orders.append(work_order)
        
        df = pd.DataFrame(work_orders)
        df.to_csv(self.output_dir / f'{sector}_work_orders.csv', index=False)
        return df
    
    def _generate_parts_used(self):
        """Generate list of parts used in a work order"""
        num_parts = random.randint(1, 5)
        parts = []
        
        for _ in range(num_parts):
            parts.append({
                'part_id': f"PRT-{fake.bothify('??###')}",
                'quantity': random.randint(1, 10),
                'unit_cost': random.uniform(10, 1000)
            })
        
        return json.dumps(parts)
    
    def generate_operational_data(self, sector, assets_df):
        """Generate operational performance data"""
        operational_data = []
        
        # Generate hourly readings for each asset
        for _, asset in assets_df.iterrows():
            dates = pd.date_range(
                start=pd.to_datetime(asset['installation_date']),
                end=self.end_date,
                freq='h'
            )
            
            # Base performance metrics
            base_efficiency = random.uniform(0.85, 0.95)
            base_temperature = random.uniform(60, 80)
            base_pressure = random.uniform(80, 120)
            base_vibration = random.uniform(0.1, 0.3)
            
            for date in dates:
                # Add daily and seasonal patterns
                hour_factor = 1 + 0.1 * np.sin(2 * np.pi * date.hour / 24)
                season_factor = 1 + 0.15 * np.sin(2 * np.pi * date.dayofyear / 365)
                
                # Generate reading with noise and patterns
                reading = {
                    'asset_id': asset['asset_id'],
                    'timestamp': date,
                    'operational_status': 'Running' if random.random() < 0.95 else 'Standby',
                    'efficiency': base_efficiency * hour_factor * season_factor + random.uniform(-0.05, 0.05),
                    'temperature': base_temperature * hour_factor * season_factor + random.uniform(-2, 2),
                    'pressure': base_pressure * hour_factor + random.uniform(-5, 5),
                    'vibration': base_vibration + random.uniform(-0.05, 0.05),
                    'utilization': random.uniform(0.7, 1.0) * hour_factor,
                    'quality_score': random.uniform(0.9, 1.0),
                    'energy_consumption': random.uniform(50, 100) * hour_factor * season_factor
                }
                
                # Calculate CAPEX and OPEX
                # CAPEX: Major investments and upgrades
                capex = 0
                if random.random() < 0.01:  # 1% chance of CAPEX event
                    capex = random.uniform(10000, 100000)
                
                # OPEX: Daily operational costs
                base_opex = random.uniform(100, 500)
                opex = base_opex * hour_factor
                
                # Add maintenance costs to OPEX
                if random.random() < 0.05:  # 5% chance of maintenance
                    opex += random.uniform(1000, 5000)
                
                # Update reading with CAPEX and OPEX
                reading['capex'] = capex
                reading['opex'] = opex
                
                operational_data.append(reading)
        
        df = pd.DataFrame(operational_data)
        df.to_csv(self.output_dir / f'{sector}_operational_data.csv', index=False)
        return df
    
    def generate_all_data(self):
        """Generate all industrial IoT data"""
        for sector in self.config['sectors'].keys():
            print(f"Generating data for {sector}...")
            
            print("  Generating asset master data...")
            assets_df = self.generate_asset_master_data(sector)
            
            print("  Generating work orders...")
            work_orders_df = self.generate_work_orders(sector, assets_df)
            
            print("  Generating operational data...")
            operational_data_df = self.generate_operational_data(sector, assets_df)
            
            print(f"Completed generating data for {sector}")
        
        print("Data generation complete! Files saved in 'industrial_data' directory.")

if __name__ == "__main__":
    generator = IndustrialIoTGenerator()
    generator.generate_all_data() 