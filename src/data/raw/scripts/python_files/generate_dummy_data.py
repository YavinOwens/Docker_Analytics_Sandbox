from faker import Faker
import pandas as pd
from datetime import datetime

# Initialize Faker
fake = Faker()

# Number of records to generate
num_records = 100

# Generate dummy data
data = {
    'name': [fake.name() for _ in range(num_records)],
    'email': [fake.email() for _ in range(num_records)],
    'phone': [fake.phone_number() for _ in range(num_records)],
    'address': [fake.address() for _ in range(num_records)],
    'company': [fake.company() for _ in range(num_records)],
    'job': [fake.job() for _ in range(num_records)],
    'date_of_birth': [fake.date_of_birth(minimum_age=18, maximum_age=80).strftime('%Y-%m-%d') for _ in range(num_records)],
    'salary': [fake.random_int(min=30000, max=150000) for _ in range(num_records)],
    'created_at': [datetime.now().strftime('%Y-%m-%d %H:%M:%S') for _ in range(num_records)]
}

# Create DataFrame
df = pd.DataFrame(data)

# Save to CSV
df.to_csv('dummy_data.csv', index=False)
print(f"Generated {num_records} records and saved to dummy_data.csv")

# Display first few records
print("\nFirst 5 records:")
print(df.head()) 