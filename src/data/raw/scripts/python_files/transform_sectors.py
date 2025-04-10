import pandas as pd
import os
import uuid
import numpy as np

# Define standard market sectors
SECTORS = [
    'Technology',
    'Healthcare',
    'Financial Services',
    'Consumer Discretionary',
    'Consumer Staples',
    'Industrials',
    'Energy',
    'Materials',
    'Real Estate',
    'Utilities',
    'Communication Services'
]

# Read the original CSV file
df = pd.read_csv('cleaned_data/financial_data/sector_performance.csv')

# Generate sector IDs
df['sector_id'] = [f'SECT_{str(uuid.uuid4())[:8]}' for _ in range(len(df))]

# Convert dates to YYYY-MM-DD format
df['transaction_date'] = pd.to_datetime(df['date']).dt.strftime('%Y-%m-%d')

# Assign sectors in a repeating pattern
df['sector_name'] = [SECTORS[i % len(SECTORS)] for i in range(len(df))]

# Rename columns to match our table structure
df = df.rename(columns={
    'performance': 'performance_score'
})

# Generate realistic market cap values based on sectors
sector_market_caps = {
    'Technology': (500000000000, 3000000000000),
    'Healthcare': (200000000000, 1000000000000),
    'Financial Services': (100000000000, 800000000000),
    'Consumer Discretionary': (50000000000, 500000000000),
    'Consumer Staples': (40000000000, 400000000000),
    'Industrials': (30000000000, 300000000000),
    'Energy': (20000000000, 250000000000),
    'Materials': (10000000000, 200000000000),
    'Real Estate': (5000000000, 100000000000),
    'Utilities': (10000000000, 150000000000),
    'Communication Services': (50000000000, 600000000000)
}

# Generate sector-specific market caps
df['market_cap'] = df.apply(lambda row: np.random.uniform(*sector_market_caps[row['sector_name']], 1)[0], axis=1)

# Generate realistic volume and volatility values
df['volume'] = df.apply(lambda row: np.random.uniform(500000, 10000000, 1)[0], axis=1)
df['volatility'] = df.apply(lambda row: np.random.uniform(0.01, 0.08, 1)[0], axis=1)

# Select and reorder columns
df = df[[
    'sector_id',
    'sector_name',
    'transaction_date',
    'performance_score',
    'market_cap',
    'volume',
    'volatility'
]]

# Create output directory if it doesn't exist
os.makedirs('transformed_data/financial_data', exist_ok=True)

# Save the transformed data
df.to_csv('transformed_data/financial_data/sector_performance.csv', index=False) 