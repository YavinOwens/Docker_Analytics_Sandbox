# Add debugging imports
import sys
import site

try:
    import cx_Oracle
    print(f"Successfully imported cx_Oracle. Path: {cx_Oracle.__file__}")
except ImportError as e:
    print(f"Error importing cx_Oracle: {e}")
    print(f"Python path: {sys.path}")
    print(f"Site packages: {site.getsitepackages()}")
    # Continue without Oracle functionality

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
import uvicorn
import os

# Try importing oracle_client with error handling
try:
    from oracle_client import oracle_client
    ORACLE_AVAILABLE = True
    # Test the Oracle connection
    if oracle_client.connect():
        print("Successfully connected to Oracle database!")
    else:
        print("Failed to connect to Oracle database, will use mock data")
        ORACLE_AVAILABLE = False
except ImportError as e:
    print(f"Error importing oracle_client: {e}")
    ORACLE_AVAILABLE = False
except Exception as e:
    print(f"Error initializing Oracle client: {e}")
    ORACLE_AVAILABLE = False

print(f"Oracle availability status: {ORACLE_AVAILABLE}")

app = FastAPI(title="RDS Analytics Hub API")

# Configure CORS with explicit origins
origins = [
    "http://localhost:3000",
    "http://localhost:3001",
    "http://react-app:3000",  # Docker internal name
    "http://rds-ui:3000",     # Docker internal name
    "http://0.0.0.0:3000",
    "http://0.0.0.0:3001",
]

# For debugging
print(f"Configuring CORS with origins: {origins}")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ConnectionConfig(BaseModel):
    host: str
    port: int
    service: str
    username: str
    password: str

class QueryRequest(BaseModel):
    connection: ConnectionConfig
    query: str

class QueryResult(BaseModel):
    columns: List[str]
    rows: List[List[Any]]

class SqlQueryRequest(BaseModel):
    query: str

@app.get("/")
def read_root():
    return {"message": "Integration API is running"}

@app.post("/execute-query", response_model=QueryResult)
async def execute_query(request: QueryRequest):
    try:
        # This is a mock implementation that returns static data
        # instead of actually connecting to Oracle
        
        # Check for errors in the connection parameters
        if request.connection.host != "oracle" or request.connection.port != 1521:
            raise HTTPException(status_code=500, detail="Invalid connection parameters")
            
        # Return dummy data for the "SELECT * FROM dual" query
        if "dual" in request.query.lower():
            return {
                "columns": ["DUMMY"],
                "rows": [["X"]]
            }
        
        # Return dummy data for other queries
        return {
            "columns": ["ID", "NAME", "VALUE"],
            "rows": [
                [1, "Test Row 1", 100],
                [2, "Test Row 2", 200],
                [3, "Test Row 3", 300],
            ]
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

# New Oracle-specific endpoints
@app.get("/api/oracle/tables")
async def get_oracle_tables():
    """Get all tables and views from the Oracle database"""
    if not ORACLE_AVAILABLE:
        return [
            { "name": "CUSTOMERS", "type": "TABLE", "schema": "ANALYTICS" },
            { "name": "ORDERS", "type": "TABLE", "schema": "ANALYTICS" },
            { "name": "PRODUCTS", "type": "TABLE", "schema": "ANALYTICS" }
        ]
    
    try:
        tables = oracle_client.get_tables()
        return tables
    except Exception as e:
        print(f"Error fetching tables: {str(e)}")
        # Fallback to mock data if there's an error
        return [
            { "name": "CUSTOMERS", "type": "TABLE", "schema": "ANALYTICS" },
            { "name": "ORDERS", "type": "TABLE", "schema": "ANALYTICS" },
            { "name": "PRODUCTS", "type": "TABLE", "schema": "ANALYTICS" }
        ]

@app.get("/api/oracle/tables/{table_name}/schema")
async def get_oracle_table_schema(table_name: str):
    """Get the schema of a specific Oracle table"""
    mock_schemas = {
        'CUSTOMERS': [
            { "column_name": "CUSTOMER_ID", "data_type": "NUMBER", "nullable": "N", "primary_key": "Y" },
            { "column_name": "NAME", "data_type": "VARCHAR2(100)", "nullable": "N", "primary_key": "N" },
            { "column_name": "EMAIL", "data_type": "VARCHAR2(100)", "nullable": "Y", "primary_key": "N" }
        ],
        'ORDERS': [
            { "column_name": "ORDER_ID", "data_type": "NUMBER", "nullable": "N", "primary_key": "Y" },
            { "column_name": "CUSTOMER_ID", "data_type": "NUMBER", "nullable": "N", "primary_key": "N" },
            { "column_name": "ORDER_DATE", "data_type": "DATE", "nullable": "N", "primary_key": "N" }
        ],
        'PRODUCTS': [
            { "column_name": "PRODUCT_ID", "data_type": "NUMBER", "nullable": "N", "primary_key": "Y" },
            { "column_name": "NAME", "data_type": "VARCHAR2(100)", "nullable": "N", "primary_key": "N" },
            { "column_name": "PRICE", "data_type": "NUMBER(10,2)", "nullable": "N", "primary_key": "N" }
        ]
    }
    
    if not ORACLE_AVAILABLE:
        return mock_schemas.get(table_name.upper(), [])
        
    try:
        schema = oracle_client.get_table_schema(table_name)
        return schema
    except Exception as e:
        print(f"Error fetching table schema: {str(e)}")
        # Fallback to mock data if there's an error
        return mock_schemas.get(table_name.upper(), [])

@app.post("/api/oracle/query")
async def execute_oracle_query(request: SqlQueryRequest):
    """Execute a SQL query on the Oracle database"""
    mock_data = {
        "columns": ["ID", "NAME", "VALUE"],
        "rows": [
            [1, "Mock Data 1", 100],
            [2, "Mock Data 2", 200],
            [3, "Mock Data 3", 300],
        ]
    }
    
    if not ORACLE_AVAILABLE:
        return mock_data
        
    try:
        result = oracle_client.execute_query(request.query)
        return result
    except Exception as e:
        print(f"Error executing query: {str(e)}")
        # Fallback to mock data if there's an error
        return mock_data

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) 