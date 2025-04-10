#!/usr/bin/env python3
"""
Example script demonstrating Oracle-Langflow-LLM integration.
This script shows how to:
1. Extract data from Oracle
2. Process it with Langchain
3. Use it with Langflow
"""

import os
import json
import pandas as pd
import cx_Oracle
from langflow_client import LangflowClient
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
)

# Connection details
ORACLE_CONNECTION_STRING = "system/oracle@oracle:1521/FREEPDB1"
LANGFLOW_URL = os.environ.get("LANGFLOW_URL", "http://langflow:7860")

class OracleLangflowIntegration:
    """Class for integrating Oracle with Langflow"""
    
    def __init__(self):
        """Initialize the integration with Oracle and Langflow connections"""
        self.oracle_connection = None
        self.langflow_client = LangflowClient(LANGFLOW_URL)
        self.connect_oracle()
    
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
    
    def format_data_for_llm(self, df, format_type='text'):
        """Format DataFrame for LLM consumption"""
        if df.empty:
            return "No data available."
        
        if format_type == 'json':
            return df.to_json(orient='records')
        elif format_type == 'csv':
            return df.to_csv(index=False)
        else:  # text format
            rows = []
            for _, row in df.iterrows():
                row_str = ", ".join([f"{col}: {val}" for col, val in row.items()])
                rows.append(row_str)
            return "\n".join(rows)
    
    def create_oracle_langflow(self, flow_name, query):
        """Create a Langflow that uses Oracle data"""
        # This is a simplified example - in a real scenario, 
        # you would use the Langflow UI to create the flow
        # and then use the API to run it with data from Oracle
        
        flow_data = {
            "name": flow_name,
            "description": "Flow that processes Oracle data with an LLM",
            "data": {
                "nodes": [],  # Simplified - you'd define your flow structure here
                "edges": []   # Simplified - you'd define connections between nodes here
            }
        }
        
        try:
            response = self.langflow_client.session.post(
                f"{LANGFLOW_URL}/api/v1/flows",
                json=flow_data
            )
            response.raise_for_status()
            logging.info(f"Created Langflow: {flow_name}")
            return response.json()
        except Exception as e:
            logging.error(f"Error creating Langflow: {e}")
            return None
    
    def run_example(self):
        """Run an example Oracle-Langflow integration"""
        logging.info("Starting Oracle-Langflow integration example")
        
        # Step 1: Query Oracle for sample data
        query = "SELECT * FROM ALL_TABLES WHERE ROWNUM < 20"
        data = self.query_oracle(query)
        
        if data.empty:
            logging.error("No data retrieved from Oracle")
            return
        
        # Step 2: Format data for LLM
        formatted_data = self.format_data_for_llm(data)
        logging.info(f"Formatted data example:\n{formatted_data[:200]}...")
        
        # Step 3: Check if Langflow is accessible
        try:
            health_response = self.langflow_client.session.get(f"{LANGFLOW_URL}/api/v1/health")
            health_response.raise_for_status()
            logging.info("Langflow is healthy and accessible")
            
            # Step 4: List available flows
            try:
                flows = self.langflow_client.list_flows()
                if isinstance(flows, pd.DataFrame) and not flows.empty:
                    logging.info(f"Available flows:\n{flows[['name', 'id']]}")
                else:
                    logging.info("No flows found in Langflow")
                    
                    # Step 5: Create example flow
                    logging.info("Creating example flow in Langflow")
                    flow = self.create_oracle_langflow("Oracle_Table_Analysis", query)
                    if flow:
                        logging.info(f"Created flow: {flow.get('name', 'Unknown')} with ID: {flow.get('id', 'Unknown')}")
            except Exception as e:
                logging.error(f"Error accessing Langflow API: {e}")
        except Exception as e:
            logging.error(f"Langflow is not accessible: {e}")
            logging.info("Please ensure the Langflow service is running")
        
        logging.info("Example completed")
        
        if self.oracle_connection:
            self.oracle_connection.close()
            logging.info("Oracle connection closed")

if __name__ == "__main__":
    integration = OracleLangflowIntegration()
    integration.run_example() 