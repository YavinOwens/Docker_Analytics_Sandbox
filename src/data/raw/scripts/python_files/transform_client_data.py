import pandas as pd
import os

# Read the original CSV file
df = pd.read_csv('cleaned_data/financial_data/client_portfolios.csv')

# Create a new DataFrame with the desired structure
transformed_df = pd.DataFrame()

# For each client, create multiple portfolio entries with different products
for idx, row in df.iterrows():
    client_id = f'CLIENT_{int(float(row["client_id"])) if pd.notna(row["client_id"]) else idx}'
    
    # Create 3 portfolio entries for each client with different products
    for i in range(3):
        portfolio_entry = {
            'portfolio_id': f'PORT_{client_id}_{i+1}',
            'client_id': client_id,
            'product_id': f'FUND_{i}',  # Using the first few funds for each client
            'transaction_date': row['account_open_date'][:10] if pd.notna(row['account_open_date']) else '2024-01-01',
            'quantity': int(100 * (i + 1)),  # Different quantities for diversification
            'value': float(row['account_balance']) / 3 if pd.notna(row['account_balance']) else 10000.0
        }
        transformed_df = pd.concat([transformed_df, pd.DataFrame([portfolio_entry])], ignore_index=True)

# Create output directory if it doesn't exist
os.makedirs('transformed_data/financial_data', exist_ok=True)

# Save the transformed data
transformed_df.to_csv('transformed_data/financial_data/client_portfolios.csv', index=False) 