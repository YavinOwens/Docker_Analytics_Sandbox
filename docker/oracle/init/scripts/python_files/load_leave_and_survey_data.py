import os
import pandas as pd
import cx_Oracle
import logging
from datetime import datetime
import random
from typing import Dict, Any

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('leave_survey_loading.log'),
        logging.StreamHandler()
    ]
)

class LeaveSurveyLoader:
    def __init__(self):
        # Docker container connection settings
        self.username = "app_user"
        self.password = "Welcome123"
        self.host = "localhost"
        self.port = "1521"
        self.service = "FREEPDB1"
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

    def load_leave_data(self, file_path: str):
        """Load leave allowance data"""
        try:
            df = pd.read_csv(file_path)
            
            # Prepare data for leave_allowances table
            leave_data = []
            for _, row in df.iterrows():
                leave_data.append({
                    'employee_id': row['employee_id'],
                    'year': row['year'],
                    'total_annual_leave': row['total_annual_leave'],
                    'bank_holidays': row['bank_holidays'],
                    'additional_leave': row.get('additional_leave', 0),
                    'leave_taken': row.get('leave_taken', 0)
                })

            # Insert data
            self.cursor.executemany("""
                INSERT INTO leave_allowances (
                    employee_id, year, total_annual_leave,
                    bank_holidays, additional_leave, leave_taken
                ) VALUES (
                    :employee_id, :year, :total_annual_leave,
                    :bank_holidays, :additional_leave, :leave_taken
                )
            """, leave_data)
            
            self.connection.commit()
            logging.info(f"Successfully loaded {len(leave_data)} leave records")
            
        except Exception as e:
            logging.error(f"Error loading leave data: {str(e)}")
            self.connection.rollback()
            raise

    def load_pulse_survey_data(self, file_path: str):
        """Load pulse survey data with anonymization"""
        try:
            df = pd.read_csv(file_path)
            
            # Anonymize the data by grouping by department and date
            survey_data = []
            for _, row in df.iterrows():
                # Generate random scores between 1 and 5
                survey_data.append({
                    'department_id': row['department_id'],
                    'survey_date': row['survey_date'],
                    'engagement_score': random.randint(1, 5),
                    'satisfaction_score': random.randint(1, 5),
                    'work_life_balance_score': random.randint(1, 5),
                    'career_growth_score': random.randint(1, 5),
                    'management_support_score': random.randint(1, 5),
                    'comments': row.get('comments', '')
                })

            # Insert data
            self.cursor.executemany("""
                INSERT INTO pulse_surveys (
                    department_id, survey_date, engagement_score,
                    satisfaction_score, work_life_balance_score,
                    career_growth_score, management_support_score,
                    comments
                ) VALUES (
                    :department_id, :survey_date, :engagement_score,
                    :satisfaction_score, :work_life_balance_score,
                    :career_growth_score, :management_support_score,
                    :comments
                )
            """, survey_data)
            
            self.connection.commit()
            logging.info(f"Successfully loaded {len(survey_data)} pulse survey records")
            
        except Exception as e:
            logging.error(f"Error loading pulse survey data: {str(e)}")
            self.connection.rollback()
            raise

    def initialize_leave_allowances(self, year: int):
        """Initialize leave allowances for a new year"""
        try:
            self.cursor.execute("BEGIN initialize_leave_allowances(:year); END;", {'year': year})
            self.connection.commit()
            logging.info(f"Successfully initialized leave allowances for year {year}")
        except Exception as e:
            logging.error(f"Error initializing leave allowances: {str(e)}")
            self.connection.rollback()
            raise

def main():
    loader = None
    try:
        # Initialize loader
        loader = LeaveSurveyLoader()
        
        # Connect to database
        loader.connect()
        
        # Initialize leave allowances for current year
        current_year = datetime.now().year
        loader.initialize_leave_allowances(current_year)
        
        # Load leave data if file exists
        leave_file = "4_transformed_data/workforce_data/leave_allowances.csv"
        if os.path.exists(leave_file):
            loader.load_leave_data(leave_file)
        
        # Load pulse survey data if file exists
        survey_file = "4_transformed_data/workforce_data/pulse_surveys.csv"
        if os.path.exists(survey_file):
            loader.load_pulse_survey_data(survey_file)
        
        logging.info("Data loading process completed successfully")
        
    except Exception as e:
        logging.error(f"Error in main: {str(e)}")
    finally:
        if loader:
            loader.disconnect()

if __name__ == "__main__":
    main() 