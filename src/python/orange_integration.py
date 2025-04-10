#!/usr/bin/env python3
"""
Example script demonstrating Oracle-Orange integration.
This script shows how to:
1. Extract data from Oracle
2. Process and prepare it for Orange
3. Save workflows and results for Orange Data Mining
"""

import os
import pandas as pd
import cx_Oracle
import numpy as np
import json
import logging
from datetime import datetime
from pathlib import Path

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
)

# Connection details
ORACLE_CONNECTION_STRING = "system/oracle@oracle:1521/FREEPDB1"
ORANGE_WORKSPACE = "/orange-data/workspace"

class OracleOrangeIntegration:
    """Class for integrating Oracle with Orange Data Mining"""
    
    def __init__(self):
        """Initialize the integration with Oracle connection"""
        self.oracle_connection = None
        self.connect_oracle()
        
        # Create Orange workspace directory if it doesn't exist
        self.workspace_dir = Path("/workspace/orange")
        self.workspace_dir.mkdir(exist_ok=True)
    
    def connect_oracle(self):
        """Connect to Oracle database"""
        try:
            self.oracle_connection = cx_Oracle.connect(ORACLE_CONNECTION_STRING)
            logging.info("Connected to Oracle database")
            return True
        except cx_Oracle.Error as error:
            logging.error(f"Error connecting to Oracle: {error}")
            return False
    
    def query_oracle(self, query):
        """Execute SQL query and return results as DataFrame"""
        try:
            if not self.oracle_connection or self.oracle_connection.ping() != 0:
                self.connect_oracle()
            
            df = pd.read_sql(query, self.oracle_connection)
            logging.info(f"Query executed successfully, retrieved {len(df)} rows")
            return df
        except Exception as e:
            logging.error(f"Error executing query: {e}")
            return pd.DataFrame()
    
    def save_for_orange(self, df, name, file_format="csv"):
        """Save DataFrame in a format for Orange Data Mining"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{name}_{timestamp}.{file_format}"
        filepath = self.workspace_dir / filename
        
        try:
            if file_format.lower() == "csv":
                df.to_csv(filepath, index=False)
            elif file_format.lower() == "tab":
                # Orange prefers tab-delimited files
                df.to_csv(filepath, sep='\t', index=False)
            elif file_format.lower() == "xlsx":
                df.to_excel(filepath, index=False)
            else:
                raise ValueError(f"Unsupported format: {file_format}")
            
            logging.info(f"Saved data to {filepath} for Orange Data Mining")
            return filepath
        except Exception as e:
            logging.error(f"Error saving data for Orange: {e}")
            return None
    
    def create_orange_metadata(self, df, name):
        """Create metadata file for Orange Data Mining"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"{name}_{timestamp}.metadata"
        filepath = self.workspace_dir / filename
        
        # Create simple metadata for Orange
        metadata = {
            "name": name,
            "description": f"Data extracted from Oracle on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            "columns": []
        }
        
        # Add column metadata
        for col in df.columns:
            col_type = "categorical" if pd.api.types.is_categorical_dtype(df[col]) else \
                      "numeric" if pd.api.types.is_numeric_dtype(df[col]) else \
                      "datetime" if pd.api.types.is_datetime64_dtype(df[col]) else \
                      "string"
            
            metadata["columns"].append({
                "name": col,
                "type": col_type,
                "missing_values": int(df[col].isna().sum())
            })
        
        try:
            with open(filepath, 'w') as f:
                json.dump(metadata, f, indent=2)
            
            logging.info(f"Created metadata file at {filepath}")
            return filepath
        except Exception as e:
            logging.error(f"Error creating metadata for Orange: {e}")
            return None
    
    def prepare_sample_data(self):
        """Prepare some sample data for Orange Data Mining"""
        # Create a synthetic dataset if no data is available from Oracle
        np.random.seed(42)
        
        data = {
            'id': range(1, 101),
            'numeric_feature1': np.random.normal(0, 1, 100),
            'numeric_feature2': np.random.normal(5, 2, 100),
            'categorical_feature': np.random.choice(['A', 'B', 'C'], 100),
            'target': np.random.choice([0, 1], 100)
        }
        
        return pd.DataFrame(data)
    
    def run_example(self):
        """Run an example Oracle-Orange integration"""
        logging.info("Starting Oracle-Orange integration example")
        
        # Step 1: Query Oracle for sample data
        query = "SELECT * FROM ALL_TABLES WHERE ROWNUM < 100"
        data = self.query_oracle(query)
        
        if data.empty:
            logging.warning("No data retrieved from Oracle, preparing synthetic data")
            data = self.prepare_sample_data()
        
        # Step 2: Save the data for Orange in different formats
        csv_path = self.save_for_orange(data, "oracle_data", "csv")
        tab_path = self.save_for_orange(data, "oracle_data", "tab")
        
        # Step 3: Create metadata for Orange
        metadata_path = self.create_orange_metadata(data, "oracle_data")
        
        # Step 4: Instructions for loading into Orange
        orange_instructions = f"""
        To use this data in Orange Data Mining:
        
        1. Access Orange Data Mining at http://localhost:6901 (password: orangeadmin)
        2. In Orange, use the 'File' widget and select one of these files:
           - CSV: {csv_path}
           - TAB: {tab_path}
        3. Connect the File widget to other widgets for visualization and analysis
        
        The data contains {len(data)} rows and {len(data.columns)} columns.
        Column types: {', '.join([f"{col}: {data[col].dtype}" for col in data.columns])}
        """
        
        print(orange_instructions)
        logging.info("Example completed")
        
        # Step 5: Create a simple Orange workflow file (JSON format)
        # This is a very simplified version - real workflows would be more complex
        workflow = {
            "version": 1,
            "widgets": [
                {
                    "name": "File",
                    "id": "file-widget",
                    "parameters": {
                        "recent_files": [str(csv_path)]
                    },
                    "position": [100, 100]
                },
                {
                    "name": "Data Table",
                    "id": "data-table-widget",
                    "parameters": {},
                    "position": [300, 100]
                },
                {
                    "name": "Scatter Plot",
                    "id": "scatter-plot-widget",
                    "parameters": {},
                    "position": [300, 250]
                }
            ],
            "connections": [
                {"from": "file-widget", "to": "data-table-widget"},
                {"from": "file-widget", "to": "scatter-plot-widget"}
            ]
        }
        
        workflow_path = self.workspace_dir / f"sample_workflow_{datetime.now().strftime('%Y%m%d_%H%M%S')}.ows"
        try:
            with open(workflow_path, 'w') as f:
                json.dump(workflow, f, indent=2)
            logging.info(f"Created simplified Orange workflow at {workflow_path}")
            print(f"Sample workflow created at: {workflow_path}")
        except Exception as e:
            logging.error(f"Error creating Orange workflow: {e}")
        
        if self.oracle_connection:
            self.oracle_connection.close()
            logging.info("Oracle connection closed")

if __name__ == "__main__":
    integration = OracleOrangeIntegration()
    integration.run_example() 