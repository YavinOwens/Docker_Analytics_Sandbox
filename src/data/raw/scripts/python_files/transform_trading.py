import pandas as pd
import os
import uuid

# Read the original CSV file
df = pd.read_csv('cleaned_data/financial_data/trading_activity.csv')

# Generate transaction IDs
df['transaction_id'] = [f'TRANS_{str(uuid.uuid4())[:8]}' for _ in range(len(df))]

# Convert dates to YYYY-MM-DD format
df['transaction_date'] = pd.to_datetime(df['date']).dt.strftime('%Y-%m-%d')

# Rename columns to match our table structure
df = df.rename(columns={
    'client': 'client_id',
    'product': 'product_id',
    'type': 'transaction_type',
    'quantity': 'share_quantity',
    'price': 'price_per_share',
    'total': 'total_value',
    'fee': 'fee_amount'
})

# Create output directory if it doesn't exist
os.makedirs('transformed_data/financial_data', exist_ok=True)

# Save the transformed data
df.to_csv('transformed_data/financial_data/trading_activity.csv', index=False) 