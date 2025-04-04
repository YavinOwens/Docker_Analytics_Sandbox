import pandas as pd
import os

# Read the original CSV file
df = pd.read_csv('cleaned_data/financial_data/investment_products.csv')

# Create a new DataFrame with the desired structure
transformed_df = pd.DataFrame({
    'product_id': 'FUND_' + df.index.astype(str),  # Create unique product IDs
    'product_name': 'Fund ' + df.index.astype(str),  # Create default names
    'product_type': 'Mutual Fund',  # Default type
    'risk_level': df['volatility'].apply(lambda x: 'High' if x > 0.1 else 'Medium' if x > 0.05 else 'Low'),
    'min_investment': 10000,  # Default minimum investment
    'management_fee': df['expense_ratio'] * 100,  # Convert to percentage
    'performance_fee': 0,  # Default performance fee
    'inception_date': '2024-01-01',  # Default inception date
    'status': 'Active'  # Default status
})

# Create output directory if it doesn't exist
os.makedirs('transformed_data/financial_data', exist_ok=True)

# Save the transformed data
transformed_df.to_csv('transformed_data/financial_data/investment_products.csv', index=False) 