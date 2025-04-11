from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Dict, Any, List, Optional
import uvicorn
from .ui_integration import DockerServiceManager
import cx_Oracle

app = FastAPI(title="RDS Analytics Hub API")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

manager = DockerServiceManager()

class ServiceStatus(BaseModel):
    running: bool
    port: int
    url: str

class ClusterInfo(BaseModel):
    name: str
    status: str
    workers: int
    memory: str

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

@app.get("/api/services/status", response_model=Dict[str, ServiceStatus])
async def get_services_status():
    """Get status of all Docker services"""
    return manager.get_service_status()

@app.post("/api/services/start")
async def start_services():
    """Start all Docker services"""
    result = manager.start_services()
    if 'error' in result:
        raise HTTPException(status_code=500, detail=result['error'])
    return result

@app.post("/api/services/stop")
async def stop_services():
    """Stop all Docker services"""
    result = manager.stop_services()
    if 'error' in result:
        raise HTTPException(status_code=500, detail=result['error'])
    return result

@app.get("/api/cluster/info", response_model=ClusterInfo)
async def get_cluster_info():
    """Get cluster information"""
    status = manager.get_service_status()
    return ClusterInfo(
        name="Standard_Cluster",
        status="Running" if status['spark_master']['running'] else "Stopped",
        workers=4,
        memory="32GB"
    )

@app.get("/api/notebooks")
async def list_notebooks():
    """List available notebooks"""
    # This would typically read from a directory or database
    return [
        {
            "id": "1",
            "name": "Customer Segmentation",
            "last_modified": "2 hours ago",
            "author": "John Doe"
        }
    ]

@app.get("/api/jobs")
async def list_jobs():
    """List scheduled jobs"""
    return [
        {
            "name": "Daily ETL Pipeline",
            "schedule": "Daily @ 2:00 AM",
            "last_run": "Apr 11, 2025 2:00 AM",
            "status": "Success"
        },
        {
            "name": "Customer ML Model Training",
            "schedule": "Weekly on Sunday",
            "last_run": "Apr 6, 2025 4:00 AM",
            "status": "Success"
        }
    ]

@app.post("/execute-query", response_model=QueryResult)
async def execute_query(request: QueryRequest):
    try:
        dsn = cx_Oracle.makedsn(
            host=request.connection.host,
            port=request.connection.port,
            service_name=request.connection.service
        )
        
        connection = cx_Oracle.connect(
            user=request.connection.username,
            password=request.connection.password,
            dsn=dsn
        )
        
        cursor = connection.cursor()
        cursor.execute(request.query)
        
        # Get column names
        columns = [col[0] for col in cursor.description] if cursor.description else []
        
        # Fetch all rows
        rows = cursor.fetchall()
        
        # Convert rows to list of lists for JSON serialization
        serializable_rows = []
        for row in rows:
            serializable_row = []
            for item in row:
                if isinstance(item, (cx_Oracle.LOB, cx_Oracle.CLOB, cx_Oracle.BLOB)):
                    serializable_row.append(str(item.read()))
                else:
                    serializable_row.append(item)
            serializable_rows.append(serializable_row)
            
        cursor.close()
        connection.close()
        
        return {"columns": columns, "rows": serializable_rows}
        
    except cx_Oracle.Error as e:
        raise HTTPException(status_code=500, detail=f"Oracle error: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) 