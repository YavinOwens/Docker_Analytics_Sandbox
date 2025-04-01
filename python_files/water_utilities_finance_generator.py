import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import random
from pathlib import Path
import json
from scipy import stats
import yaml

# Set random seeds for reproducibility
RANDOM_SEED = 42
np.random.seed(RANDOM_SEED)
random.seed(RANDOM_SEED)

class WaterUtilitiesFinanceGenerator:
    def __init__(self):
        self.start_date = datetime(2019, 1, 1)
        self.end_date = datetime.now()
        
        # Create output directory
        self.output_dir = Path('water_utilities_finance')
        self.output_dir.mkdir(exist_ok=True)
        
        # Load configuration
        self.config = self._load_config()
        
        # Initialize counters
        self.transaction_counter = 0
        self.budget_counter = 0
    
    def _load_config(self):
        """Load configuration from YAML file"""
        with open('finance_config.yaml', 'r') as f:
            return yaml.safe_load(f)
        
    def generate_financial_statements(self):
        """Generate monthly financial statements"""
        financial_data = []
        
        # Generate monthly records from 2019 to present
        current_date = self.start_date
        while current_date <= self.end_date:
            # Generate base revenue with seasonal variations
            base_revenue = random.uniform(5000000, 8000000)
            season_factor = 1.0
            if current_date.month in [6, 7, 8]:  # Summer
                season_factor = self.config['revenue']['components']['water_sales']['seasonal_factors']['summer']
            elif current_date.month in [12, 1, 2]:  # Winter
                season_factor = self.config['revenue']['components']['water_sales']['seasonal_factors']['winter']
            
            # Calculate revenue components using config
            water_sales = base_revenue * self.config['revenue']['components']['water_sales']['base_percentage'] * season_factor
            wastewater_charges = base_revenue * self.config['revenue']['components']['wastewater_charges']['base_percentage'] * season_factor
            connection_fees = base_revenue * self.config['revenue']['components']['connection_fees']['base_percentage'] * random.uniform(*self.config['revenue']['components']['connection_fees']['variation_range'])
            
            # Calculate operating costs using config
            labor_costs = base_revenue * random.uniform(*self.config['costs']['components']['labor']['percentage_range'])
            materials_costs = base_revenue * random.uniform(*self.config['costs']['components']['materials']['percentage_range'])
            energy_costs = base_revenue * random.uniform(*self.config['costs']['components']['energy']['percentage_range'])
            maintenance_costs = base_revenue * random.uniform(*self.config['costs']['components']['maintenance']['percentage_range'])
            other_costs = base_revenue * random.uniform(*self.config['costs']['components']['other']['percentage_range'])
            
            # Calculate financial metrics
            total_revenue = water_sales + wastewater_charges + connection_fees
            total_costs = labor_costs + materials_costs + energy_costs + maintenance_costs + other_costs
            operating_income = total_revenue - total_costs
            net_income = operating_income * random.uniform(0.7, 0.9)  # After taxes and other expenses
            
            # Generate financial record
            financial_record = {
                'period': current_date.strftime('%Y-%m'),
                'year': current_date.year,
                'month': current_date.month,
                'water_sales': round(water_sales, 2),
                'wastewater_charges': round(wastewater_charges, 2),
                'connection_fees': round(connection_fees, 2),
                'total_revenue': round(total_revenue, 2),
                'labor_costs': round(labor_costs, 2),
                'materials_costs': round(materials_costs, 2),
                'energy_costs': round(energy_costs, 2),
                'maintenance_costs': round(maintenance_costs, 2),
                'other_costs': round(other_costs, 2),
                'total_costs': round(total_costs, 2),
                'operating_income': round(operating_income, 2),
                'net_income': round(net_income, 2),
                'operating_margin': round(operating_income / total_revenue * 100, 2),
                'net_margin': round(net_income / total_revenue * 100, 2),
                'revenue_growth': round(random.uniform(*self.config['financial_metrics']['revenue_growth']['range']), 2),
                'cost_efficiency': round(random.uniform(*self.config['financial_metrics']['cost_efficiency']['range']), 2),
                'water_loss_percentage': round(random.uniform(*self.config['financial_metrics']['water_loss_percentage']['range']), 2),
                'energy_efficiency': round(random.uniform(*self.config['financial_metrics']['energy_efficiency']['range']), 2)
            }
            
            financial_data.append(financial_record)
            current_date += timedelta(days=30)  # Move to next month
        
        df = pd.DataFrame(financial_data)
        df.to_csv(self.output_dir / 'financial_statements.csv', index=False)
        return df
    
    def generate_budgets(self):
        """Generate annual budgets and forecasts"""
        budget_data = []
        
        # Generate annual budgets from 2019 to present
        for year in range(self.start_date.year, self.end_date.year + 1):
            # Generate base budget using config
            base_budget = random.uniform(*self.config['budget']['base_range'])
            
            # Generate budget components using config
            budget_record = {
                'year': year,
                'budget_id': f"BUD-{year}-{random.randint(1000, 9999)}",
                'total_budget': round(base_budget, 2),
                'operational_budget': round(base_budget * self.config['budget']['allocations']['operational'], 2),
                'capital_budget': round(base_budget * self.config['budget']['allocations']['capital'], 2),
                'maintenance_budget': round(base_budget * self.config['budget']['allocations']['maintenance'], 2),
                'labor_budget': round(base_budget * self.config['budget']['allocations']['labor'], 2),
                'materials_budget': round(base_budget * self.config['budget']['allocations']['materials'], 2),
                'energy_budget': round(base_budget * self.config['budget']['allocations']['energy'], 2),
                'technology_budget': round(base_budget * self.config['budget']['allocations']['technology'], 2),
                'safety_budget': round(base_budget * self.config['budget']['allocations']['safety'], 2),
                'training_budget': round(base_budget * self.config['budget']['allocations']['training'], 2),
                'contingency_budget': round(base_budget * self.config['budget']['allocations']['contingency'], 2),
                'status': random.choice(self.config['budget']['status_options']),
                'approved_by': f"DIR-{random.randint(1000, 9999)}",
                'approval_date': datetime(year, random.randint(1, 12), random.randint(1, 28)),
                'budget_notes': json.dumps(random.sample(self.config['budget_notes'], k=random.randint(3, 5)))
            }
            
            budget_data.append(budget_record)
        
        df = pd.DataFrame(budget_data)
        df.to_csv(self.output_dir / 'budgets.csv', index=False)
        return df
    
    def generate_cash_flow(self):
        """Generate daily cash flow transactions"""
        cash_flow_data = []
        
        # Generate daily transactions from 2019 to present
        current_date = self.start_date
        while current_date <= self.end_date:
            # Generate multiple transactions per day using config
            num_transactions = random.randint(*self.config['transactions']['daily_range'])
            
            for _ in range(num_transactions):
                self.transaction_counter += 1
                transaction_id = f"TRX-{self.transaction_counter:06d}"
                
                # Generate transaction data using config
                amount = random.uniform(100, 100000)
                transaction_type = random.choice(list(self.config['transactions']['types'].keys()))
                transaction_config = self.config['transactions']['types'][transaction_type]
                
                # Determine if inflow or outflow
                is_inflow = transaction_type in ['Customer Payment', 'Service Fee']
                
                transaction = {
                    'transaction_id': transaction_id,
                    'date': current_date,
                    'transaction_type': transaction_type,
                    'amount': round(amount, 2),
                    'is_inflow': is_inflow,
                    'payment_method': random.choice(self.config['payment_methods']),
                    'status': random.choice(self.config['transaction_status']),
                    'reference_number': f"REF-{random.randint(100000, 999999)}",
                    'description': random.choice(transaction_config['descriptions']),
                    'category': transaction_config['category']
                }
                
                cash_flow_data.append(transaction)
            
            current_date += timedelta(days=1)
        
        df = pd.DataFrame(cash_flow_data)
        df.to_csv(self.output_dir / 'cash_flow.csv', index=False)
        return df
    
    def generate_all_data(self):
        """Generate all financial data"""
        print("\n=== Starting Water Utilities Finance Data Generation ===")
        print(f"Start Date: {self.start_date.strftime('%Y-%m-%d')}")
        print(f"End Date: {self.end_date.strftime('%Y-%m-%d')}")
        print(f"Output Directory: {self.output_dir.absolute()}\n")
        
        print("1. Generating financial statements...")
        financial_df = self.generate_financial_statements()
        print(f"   ✓ Generated {len(financial_df)} monthly records")
        print(f"   ✓ Saved to: {self.output_dir / 'financial_statements.csv'}")
        
        print("\n2. Generating budgets...")
        budget_df = self.generate_budgets()
        print(f"   ✓ Generated {len(budget_df)} annual budgets")
        print(f"   ✓ Saved to: {self.output_dir / 'budgets.csv'}")
        
        print("\n3. Generating cash flow transactions...")
        cash_flow_df = self.generate_cash_flow()
        print(f"   ✓ Generated {len(cash_flow_df)} transactions")
        print(f"   ✓ Saved to: {self.output_dir / 'cash_flow.csv'}")
        
        print("\n=== Data Generation Summary ===")
        print(f"Total Financial Statements: {len(financial_df)}")
        print(f"Total Budgets: {len(budget_df)}")
        print(f"Total Transactions: {len(cash_flow_df)}")
        print(f"\nAll files have been saved to: {self.output_dir.absolute()}")
        print("=== Generation Complete ===\n")

if __name__ == "__main__":
    generator = WaterUtilitiesFinanceGenerator()
    generator.generate_all_data() 