import os
import pandas as pd
import cx_Oracle
import logging
from typing import Dict, Any

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('data_loading.log'),
        logging.StreamHandler()
    ]
)

class DatabaseLoader:
    def __init__(self):
        # Docker container connection settings
        self.username = "app_user"
        self.password = "Welcome123"  # Password from create_all_tables.sql
        self.host = "localhost"   # Docker host
        self.port = "1521"       # Exposed port from Docker
        self.service = "FREEPDB1"  # Service name from create_all_tables.sql
        self.connection = None
        self.cursor = None

    def connect(self):
        """Establish database connection"""
        try:
            dsn = cx_Oracle.makedsn(self.host, self.port, service_name=self.service)
            self.connection = cx_Oracle.connect(
                user=self.username,
                password=self.password,
                dsn=dsn
            )
            self.cursor = self.connection.cursor()
            logging.info("Successfully connected to the Docker Oracle database")
        except Exception as e:
            logging.error(f"Error connecting to database: {str(e)}")
            raise

    def disconnect(self):
        """Close database connection"""
        try:
            if self.cursor:
                self.cursor.close()
            if self.connection:
                self.connection.close()
            logging.info("Successfully disconnected from the database")
        except Exception as e:
            logging.error(f"Error disconnecting from database: {str(e)}")

    def load_table(self, table_name: str, df: pd.DataFrame):
        """Load data into a specific table"""
        try:
            # Get column names from the dataframe
            columns = df.columns.tolist()
            
            # Create the INSERT statement
            placeholders = ':' + ', :'.join(map(str, range(1, len(columns) + 1)))
            insert_sql = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES ({placeholders})"
            
            # Convert DataFrame to list of tuples
            data = [tuple(x) for x in df.replace({pd.NA: None}).values]
            
            # Execute batch insert
            self.cursor.executemany(insert_sql, data)
            self.connection.commit()
            
            logging.info(f"Successfully loaded {len(data)} rows into {table_name}")
            
        except Exception as e:
            logging.error(f"Error loading data into {table_name}: {str(e)}")
            self.connection.rollback()
            raise

    def load_all_data(self, base_dir: str = "cleaned_data"):
        """Load all cleaned data into the database"""
        try:
            # Directory to table name mapping
            dir_mapping = {
                'financial_data': [
                    'advisor_data', 'client_portfolios', 'interest_rates',
                    'investment_products', 'market_indices', 'sector_performance',
                    'trading_activity'
                ],
                'industrial_data': [
                    'water_utilities_assets', 'water_utilities_work_orders'
                ],
                'water_utilities_finance': [
                    'cash_flow', 'budgets', 'financial_statements'
                ],
                'water_utilities_metrics': [
                    'ofwat_results', 'pulse_surveys', 'capex_projects'
                ],
                'workforce_data': [
                    'employees', 'performance_reviews', 'leave_records',
                    'training_records'
                ]
            }

            # Process each directory
            for dir_name, tables in dir_mapping.items():
                dir_path = os.path.join(base_dir, dir_name)
                if os.path.exists(dir_path):
                    for table in tables:
                        file_path = os.path.join(dir_path, f"{table}.csv")
                        if os.path.exists(file_path):
                            try:
                                logging.info(f"Loading data from {file_path}")
                                df = pd.read_csv(file_path)
                                self.load_table(table, df)
                            except Exception as e:
                                logging.error(f"Error processing {file_path}: {str(e)}")
                else:
                    logging.warning(f"Directory not found: {dir_path}")

        except Exception as e:
            logging.error(f"Error in load_all_data: {str(e)}")
            raise

def main():
    loader = None
    try:
        # Initialize database loader
        loader = DatabaseLoader()
        
        # Connect to database
        loader.connect()
        
        # Load all data
        loader.load_all_data()
        
        logging.info("Data loading process completed successfully")
        
    except Exception as e:
        logging.error(f"Error in main: {str(e)}")
    finally:
        if loader:
            loader.disconnect()

if __name__ == "__main__":
    main() 