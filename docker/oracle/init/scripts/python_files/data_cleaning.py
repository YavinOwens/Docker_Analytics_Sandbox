import pandas as pd
import numpy as np
from datetime import datetime
import re
import os
from typing import Dict, List, Any
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('data_cleaning.log'),
        logging.StreamHandler()
    ]
)

class DataCleaner:
    def __init__(self):
        self.cleaned_data: Dict[str, pd.DataFrame] = {}
        
    def clean_date(self, date_str: str) -> str:
        """Standardize date format to YYYY-MM-DD"""
        if pd.isna(date_str):
            return None
            
        try:
            # Handle various date formats
            if isinstance(date_str, str):
                # Remove any time component
                date_str = date_str.split()[0]
                
                # Try different date formats
                for fmt in ['%Y-%m-%d', '%d/%m/%Y', '%m/%d/%Y', '%Y/%m/%d']:
                    try:
                        date = datetime.strptime(date_str, fmt)
                        return date.strftime('%Y-%m-%d')
                    except ValueError:
                        continue
                        
            return None
        except Exception as e:
            logging.error(f"Error cleaning date {date_str}: {str(e)}")
            return None

    def is_special_column(self, column_name: str) -> bool:
        """Check if a column contains special values that should not be converted to numeric"""
        special_patterns = [
            r'budget_id|budget_identifier',  # Budget identifiers
            r'period|quarter',               # Period identifiers
            r'date|timestamp',               # Date columns
            r'index_date|market_date'        # Market index dates
        ]
        return any(re.search(pattern, column_name.lower()) for pattern in special_patterns)

    def clean_numeric(self, value: Any) -> float:
        """Clean numeric values, handling various formats"""
        if pd.isna(value):
            return None
            
        try:
            if isinstance(value, str):
                # Handle empty string, single dot, dash, or whitespace
                value = value.strip()
                if not value or value in ['.', '-', '--', '...', '---']:
                    return None
                    
                # First check if it's a date string
                if re.match(r'^\d{4}-\d{2}-\d{2}$', value) or re.match(r'^\d{4}-\d{2}$', value):
                    return None
                    
                # Check if it's a budget identifier (e.g., -2019-6061)
                if re.match(r'^-\d{4}-\d+$', value):
                    return None
                    
                # Remove any currency symbols and commas
                value = re.sub(r'[^\d.-]', '', value)
                
                # Handle empty string after cleaning
                if not value:
                    return None
                    
                # Handle double negatives (e.g., "--000173")
                if value.startswith('--'):
                    value = value[2:]  # Remove both negative signs
                    
                # Handle single negative with leading zeros
                elif value.startswith('-0'):
                    value = '-' + value[1:].lstrip('0')  # Keep one negative sign and remove leading zeros
                    
                # Handle leading zeros without negative
                elif value.startswith('0'):
                    value = value.lstrip('0')  # Remove leading zeros
                    
                # Handle single negative sign at the end
                if value.endswith('-'):
                    value = '-' + value[:-1]
                    
                # Handle empty string after all cleaning
                if not value:
                    return None
                    
                # Handle concatenated decimal numbers by taking the first valid number
                if '.' in value:
                    parts = value.split('.')
                    if len(parts) > 2:  # Multiple decimal points
                        # Take the first part plus one decimal point
                        value = parts[0] + '.' + parts[1]
                    
                # Convert to float
                try:
                    return float(value)
                except ValueError:
                    # If conversion fails, it might be a string of dots or dashes
                    if all(c in '.-' for c in value):
                        return None
                    raise
                    
            return float(value)
        except Exception as e:
            logging.error(f"Error cleaning numeric value {value}: {str(e)}")
            return None

    def clean_text(self, text: str) -> str:
        """Clean text values"""
        if pd.isna(text):
            return None
            
        try:
            if isinstance(text, str):
                # Remove extra whitespace and normalize line endings
                text = ' '.join(text.split())
                return text.strip()
            return str(text)
        except Exception as e:
            logging.error(f"Error cleaning text {text}: {str(e)}")
            return None

    def clean_water_utility_assets(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean water utilities assets data"""
        logging.info("Cleaning water utilities assets data")
        
        # Clean date columns
        date_columns = ['installation_date', 'warranty_expiration']
        for col in date_columns:
            df[col] = df[col].apply(self.clean_date)
            
        # Clean numeric columns
        numeric_columns = [
            'expected_lifetime_hours', 'expected_lifetime_years',
            'purchase_cost', 'replacement_cost', 'maintenance_interval',
            'condition_score', 'criticality_rating'
        ]
        for col in numeric_columns:
            df[col] = df[col].apply(self.clean_numeric)
            
        # Clean text columns
        text_columns = ['name', 'type', 'category', 'manufacturer', 'model_number', 
                       'serial_number', 'firmware_version', 'parent_asset_id']
        for col in text_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Clean CLOB columns
        clob_columns = ['standards', 'failure_modes', 'location']
        for col in clob_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Validate operational status
        valid_statuses = ['ACTIVE', 'INACTIVE', 'MAINTENANCE', 'DECOMMISSIONED']
        df['operational_status'] = df['operational_status'].apply(
            lambda x: x.upper() if x in valid_statuses else 'ACTIVE'
        )
        
        return df

    def clean_water_utilities_work_orders(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean water utilities work orders data"""
        logging.info("Cleaning water utilities work orders data")
        
        # Clean date columns
        date_columns = ['creation_date', 'completion_date']
        for col in date_columns:
            df[col] = df[col].apply(self.clean_date)
            
        # Clean numeric columns
        numeric_columns = ['priority', 'estimated_hours', 'actual_hours', 'downtime_hours']
        for col in numeric_columns:
            df[col] = df[col].apply(self.clean_numeric)
            
        # Clean text columns
        text_columns = ['work_order_id', 'asset_id', 'type', 'assigned_technician']
        for col in text_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Clean CLOB columns
        clob_columns = ['problem_description', 'required_certifications', 
                       'parts_used', 'safety_permits']
        for col in clob_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Validate status
        valid_statuses = ['Open', 'In Progress', 'Completed', 'Cancelled', 'On Hold', 'Assigned']
        df['status'] = df['status'].apply(
            lambda x: x if x in valid_statuses else 'Open'
        )
        
        return df

    def clean_ofwat_results(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean Ofwat results data"""
        logging.info("Cleaning Ofwat results data")
        
        # Clean numeric columns
        numeric_columns = [
            'year', 'quarter_number', 'water_quality_score', 'customer_service_score',
            'leakage_reduction_score', 'water_efficiency_score', 'environmental_impact_score',
            'operational_efficiency_score', 'overall_performance_score',
            'financial_incentives_earned'
        ]
        for col in numeric_columns:
            df[col] = df[col].apply(self.clean_numeric)
            
        # Clean text columns
        text_columns = ['quarter', 'regulatory_compliance']
        for col in text_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Clean CLOB columns
        clob_columns = ['key_achievements', 'areas_for_improvement']
        for col in clob_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Validate performance rating
        valid_ratings = ['Good', 'Poor', 'Requires Improvement', 'Outstanding']
        df['performance_rating'] = df['performance_rating'].apply(
            lambda x: x if x in valid_ratings else 'Requires Improvement'
        )
        
        return df

    def clean_employees(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean employees data"""
        logging.info("Cleaning employees data")
        
        # Clean date columns
        date_columns = ['hire_date']
        for col in date_columns:
            df[col] = df[col].apply(self.clean_date)
            
        # Clean numeric columns
        numeric_columns = ['salary', 'bonus_target']
        for col in numeric_columns:
            df[col] = df[col].apply(self.clean_numeric)
            
        # Clean text columns
        text_columns = [
            'employee_id', 'first_name', 'last_name', 'email', 'phone',
            'department', 'role', 'manager_id'
        ]
        for col in text_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Clean CLOB columns
        clob_columns = ['certifications', 'skills', 'location', 'emergency_contact']
        for col in clob_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Validate employment status
        valid_statuses = ['Active', 'Inactive', 'On Leave', 'Terminated']
        df['employment_status'] = df['employment_status'].apply(
            lambda x: x if x in valid_statuses else 'Active'
        )
        
        # Validate department
        valid_departments = [
            'Operations', 'Maintenance', 'Quality Control', 'Safety',
            'Logistics', 'Training', 'HR', 'Management'
        ]
        df['department'] = df['department'].apply(
            lambda x: x if x in valid_departments else 'Operations'
        )
        
        return df

    def clean_performance_reviews(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean performance reviews data"""
        logging.info("Cleaning performance reviews data")
        
        # Clean date columns
        date_columns = ['review_date']
        for col in date_columns:
            df[col] = df[col].apply(self.clean_date)
            
        # Clean numeric columns
        numeric_columns = [
            'overall_rating', 'technical_skills', 'communication',
            'leadership', 'safety_compliance', 'attendance',
            'bonus_awarded', 'bonus_amount'
        ]
        for col in numeric_columns:
            df[col] = df[col].apply(self.clean_numeric)
            
        # Clean text columns
        text_columns = ['review_id', 'employee_id', 'reviewer_id']
        for col in text_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Clean CLOB columns
        clob_columns = ['comments', 'goals_set']
        for col in clob_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Validate ratings (1-5)
        rating_columns = [
            'overall_rating', 'technical_skills', 'communication',
            'leadership', 'safety_compliance', 'attendance'
        ]
        for col in rating_columns:
            df[col] = df[col].apply(lambda x: max(1, min(5, x)) if pd.notnull(x) else None)
            
        return df

    def clean_pulse_surveys(self, df: pd.DataFrame) -> pd.DataFrame:
        """Clean pulse surveys data"""
        logging.info("Cleaning pulse surveys data")
        
        # Clean date columns
        date_columns = ['survey_date']
        for col in date_columns:
            df[col] = df[col].apply(self.clean_date)
            
        # Clean numeric columns
        numeric_columns = [
            'response_rate', 'engagement_score', 'satisfaction_score',
            'wellbeing_score', 'culture_score', 'leadership_score',
            'development_score', 'work_life_balance_score',
            'recognition_score', 'overall_score'
        ]
        for col in numeric_columns:
            df[col] = df[col].apply(self.clean_numeric)
            
        # Clean text columns
        text_columns = ['survey_id', 'department']
        for col in text_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Clean CLOB columns
        clob_columns = ['key_findings', 'action_items', 'employee_feedback']
        for col in clob_columns:
            df[col] = df[col].apply(self.clean_text)
            
        # Validate scores (0-1)
        score_columns = [
            'engagement_score', 'satisfaction_score', 'wellbeing_score',
            'culture_score', 'leadership_score', 'development_score',
            'work_life_balance_score', 'recognition_score', 'overall_score'
        ]
        for col in score_columns:
            df[col] = df[col].apply(lambda x: max(0, min(1, x)) if pd.notnull(x) else None)
            
        return df

    def clean_financial_data(self, df: pd.DataFrame, filename: str) -> pd.DataFrame:
        """Clean financial data files"""
        logging.info(f"Cleaning financial data: {filename}")
        
        # Clean date columns
        date_columns = [col for col in df.columns if 'date' in col.lower()]
        for col in date_columns:
            df[col] = df[col].apply(self.clean_date)
            
        # Clean numeric columns, excluding special columns
        numeric_columns = [col for col in df.columns 
                         if col not in date_columns 
                         and not self.is_special_column(col)]
        for col in numeric_columns:
            df[col] = df[col].apply(self.clean_numeric)
            
        return df

    def clean_industrial_data(self, df: pd.DataFrame, filename: str) -> pd.DataFrame:
        """Clean industrial data files"""
        logging.info(f"Cleaning industrial data: {filename}")
        
        if 'water_utility_assets.csv' in filename:
            return self.clean_water_utility_assets(df)
        elif 'water_utilities_work_orders.csv' in filename:
            return self.clean_water_utilities_work_orders(df)
        else:
            return df

    def clean_water_utilities_finance(self, df: pd.DataFrame, filename: str) -> pd.DataFrame:
        """Clean water utilities finance data"""
        logging.info(f"Cleaning water utilities finance data: {filename}")
        
        # Clean date columns
        date_columns = [col for col in df.columns if 'date' in col.lower()]
        for col in date_columns:
            df[col] = df[col].apply(self.clean_date)
            
        # Clean numeric columns, excluding special columns
        numeric_columns = [col for col in df.columns 
                         if col not in date_columns 
                         and not self.is_special_column(col)]
        for col in numeric_columns:
            df[col] = df[col].apply(self.clean_numeric)
            
        return df

    def clean_water_utilities_metrics(self, df: pd.DataFrame, filename: str) -> pd.DataFrame:
        """Clean water utilities metrics data"""
        logging.info(f"Cleaning water utilities metrics data: {filename}")
        
        if 'ofwat_results.csv' in filename:
            return self.clean_ofwat_results(df)
        elif 'pulse_surveys.csv' in filename:
            return self.clean_pulse_surveys(df)
        else:
            # Clean capex_projects.csv
            date_columns = [col for col in df.columns if 'date' in col.lower()]
            for col in date_columns:
                df[col] = df[col].apply(self.clean_date)
                
            numeric_columns = [col for col in df.columns if col not in date_columns]
            for col in numeric_columns:
                df[col] = df[col].apply(self.clean_numeric)
                
            return df

    def clean_workforce_data(self, df: pd.DataFrame, filename: str) -> pd.DataFrame:
        """Clean workforce data"""
        logging.info(f"Cleaning workforce data: {filename}")
        
        if 'employees.csv' in filename:
            return self.clean_employees(df)
        elif 'performance_reviews.csv' in filename:
            return self.clean_performance_reviews(df)
        else:
            # Clean leave_records.csv and training_records.csv
            date_columns = [col for col in df.columns if 'date' in col.lower()]
            for col in date_columns:
                df[col] = df[col].apply(self.clean_date)
                
            numeric_columns = [col for col in df.columns if col not in date_columns]
            for col in numeric_columns:
                df[col] = df[col].apply(self.clean_numeric)
                
            return df

    def clean_all_data(self, base_dir: str) -> Dict[str, pd.DataFrame]:
        """Clean all data files in the specified directories"""
        logging.info(f"Starting data cleaning process in directory: {base_dir}")
        
        # Define directory mappings
        directory_mappings = {
            'financial_data': self.clean_financial_data,
            'industrial_data': self.clean_industrial_data,
            'water_utilities_finance': self.clean_water_utilities_finance,
            'water_utilities_metrics': self.clean_water_utilities_metrics,
            'workforce_data': self.clean_workforce_data
        }
        
        # Process each directory
        for dir_name, clean_func in directory_mappings.items():
            dir_path = os.path.join(base_dir, dir_name)
            if os.path.exists(dir_path):
                logging.info(f"Processing directory: {dir_name}")
                for filename in os.listdir(dir_path):
                    if filename.endswith('.csv'):
                        file_path = os.path.join(dir_path, filename)
                        try:
                            logging.info(f"Processing file: {filename}")
                            df = pd.read_csv(file_path)
                            cleaned_df = clean_func(df, filename)
                            self.cleaned_data[f"{dir_name}/{filename}"] = cleaned_df
                            logging.info(f"Successfully cleaned {filename}")
                        except Exception as e:
                            logging.error(f"Error processing {filename}: {str(e)}")
            else:
                logging.warning(f"Directory not found: {dir_name}")
        
        return self.cleaned_data

    def save_cleaned_data(self, output_dir: str):
        """Save cleaned data to CSV files"""
        logging.info(f"Saving cleaned data to directory: {output_dir}")
        
        # Create base output directory
        if not os.path.exists(output_dir):
            os.makedirs(output_dir)
            
        for filepath, df in self.cleaned_data.items():
            # Create subdirectories if they don't exist
            subdir = os.path.dirname(filepath)
            if subdir:
                output_subdir = os.path.join(output_dir, subdir)
                if not os.path.exists(output_subdir):
                    os.makedirs(output_subdir)
            
            # Remove 'cleaned_' prefix from the path to avoid double prefixing
            output_path = os.path.join(output_dir, filepath)
            try:
                df.to_csv(output_path, index=False)
                logging.info(f"Successfully saved cleaned data to {output_path}")
            except Exception as e:
                logging.error(f"Error saving {filepath}: {str(e)}")

    def get_column_types(self, data_type: str) -> Dict[str, str]:
        """Get column types based on data type"""
        # Define column types for different data types
        column_types = {
            'financial_data': {
                'date': ['date', 'timestamp', 'period'],
                'numeric': ['amount', 'value', 'price', 'rate', 'balance', 'score'],
                'categorical': ['type', 'status', 'category', 'rating']
            },
            'industrial_data': {
                'date': ['date', 'timestamp', 'created_at', 'updated_at'],
                'numeric': ['cost', 'hours', 'rating', 'score', 'amount'],
                'categorical': ['status', 'type', 'category', 'priority']
            },
            'water_utilities_finance': {
                'date': ['date', 'period', 'quarter'],
                'numeric': ['amount', 'value', 'budget', 'actual'],
                'categorical': ['status', 'type', 'category']
            },
            'water_utilities_metrics': {
                'date': ['date', 'period', 'quarter'],
                'numeric': ['score', 'rating', 'value', 'amount'],
                'categorical': ['status', 'type', 'category', 'rating']
            },
            'workforce_data': {
                'date': ['date', 'hire_date', 'review_date'],
                'numeric': ['salary', 'rating', 'score', 'amount'],
                'categorical': ['status', 'department', 'role', 'rating']
            }
        }
        return column_types.get(data_type, {})

    def clean_categorical(self, value: Any) -> str:
        """Clean categorical values"""
        if pd.isna(value):
            return None
            
        try:
            if isinstance(value, str):
                # Remove extra whitespace and normalize case
                value = ' '.join(value.split())
                return value.strip().upper()
            return str(value).strip().upper()
        except Exception as e:
            logging.error(f"Error cleaning categorical value {value}: {str(e)}")
            return None

    def clean_dataframe(self, df: pd.DataFrame, data_type: str) -> pd.DataFrame:
        """Clean a DataFrame based on its data type"""
        try:
            # Create a copy to avoid modifying the original
            df_cleaned = df.copy()
            
            # Get column types based on data type
            column_types = self.get_column_types(data_type)
            
            # First pass: clean dates
            for col in df_cleaned.columns:
                if any(date_type in col.lower() for date_type in column_types.get('date', [])):
                    df_cleaned[col] = df_cleaned[col].apply(self.clean_date)
            
            # Second pass: clean numeric values
            for col in df_cleaned.columns:
                if any(numeric_type in col.lower() for numeric_type in column_types.get('numeric', [])):
                    if not self.is_special_column(col):
                        df_cleaned[col] = df_cleaned[col].apply(self.clean_numeric)
            
            # Third pass: clean categorical values
            for col in df_cleaned.columns:
                if any(cat_type in col.lower() for cat_type in column_types.get('categorical', [])):
                    df_cleaned[col] = df_cleaned[col].apply(self.clean_categorical)
            
            return df_cleaned
            
        except Exception as e:
            logging.error(f"Error cleaning DataFrame: {str(e)}")
            return df

def main():
    # Initialize data cleaner
    cleaner = DataCleaner()
    
    # Define base directory
    base_dir = "."
    
    # Clean all data
    cleaned_data = cleaner.clean_all_data(base_dir)
    
    # Save cleaned data
    cleaner.save_cleaned_data("cleaned_data")
    
    logging.info("Data cleaning process completed")

if __name__ == "__main__":
    main() 