import pandas as pd
import os

# Read the original CSV file
df = pd.read_csv('cleaned_data/financial_data/interest_rates.csv')

# Convert dates to YYYY-MM-DD format
df['date'] = pd.to_datetime(df['date']).dt.strftime('%Y-%m-%d')

# Rename columns to match our table structure
df = df.rename(columns={
    'date': 'transaction_date',
    'fed_funds_rate': 'rate_value',
    'treasury_10y': 'rate_value_2'
})

# Add required columns
df['rate_type'] = 'FED_FUNDS'
df['effective_date'] = df['transaction_date']
df['maturity_date'] = df['transaction_date']
df['currency'] = 'USD'

# Create a second DataFrame for treasury rates
df2 = df.copy()
df2['rate_type'] = 'TREASURY_10Y'
df2['rate_value'] = df2['rate_value_2']

# Combine the DataFrames
df = pd.concat([df, df2], ignore_index=True)

# Drop the temporary column
df = df.drop('rate_value_2', axis=1)

# Create output directory if it doesn't exist
os.makedirs('transformed_data/financial_data', exist_ok=True)

# Save the transformed data
df.to_csv('transformed_data/financial_data/interest_rates.csv', index=False) 