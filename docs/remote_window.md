# Remote Window Connection Guide

This guide provides instructions for connecting to the Oracle Database and MinIO storage from different IDEs.

## Prerequisites

1. Docker containers running:
```bash
docker ps
```
You should see containers for:
- Oracle Database (sql_stuff-oracle-1)
- MinIO (sql_stuff-minio-1)

2. Required credentials:
- Oracle Database:
  - Host: localhost
  - Port: 1521
  - Service Name: FREEPDB1
  - Username: system
  - Password: Welcome123

- MinIO Storage:
  - API Endpoint: http://localhost:9000
  - Console: http://localhost:9001
  - Access Key: admin
  - Secret Key: admin123

## Cursor AI IDE Setup

### 1. Database Connection

1. Open Cursor AI IDE
2. Click on the "Database" icon in the sidebar
3. Click "Add Connection"
4. Fill in the connection details:
   - Connection Type: Oracle
   - Host: localhost
   - Port: 1521
   - Service Name: FREEPDB1
   - Username: system
   - Password: Welcome123
5. Click "Test Connection" to verify
6. Click "Save" to store the connection

### 2. MinIO Storage Connection

1. Open Cursor AI IDE
2. Click on the "Explorer" icon in the sidebar
3. Click "Add Folder"
4. Enter the MinIO mount path:
   ```
   /Users/admin/docker_stufff/sql_stuff/staging_data
   ```
5. Repeat for dumps folder:
   ```
   /Users/admin/docker_stufff/sql_stuff/data_dumps
   ```

## Visual Studio Code Setup

### 1. Database Connection

1. Install the "Oracle Database Tools" extension
2. Open the Command Palette (Cmd/Ctrl + Shift + P)
3. Type "Oracle: Add Connection"
4. Fill in the connection details:
   ```json
   {
     "name": "Local Oracle XE",
     "host": "localhost",
     "port": 1521,
     "serviceName": "FREEPDB1",
     "username": "system",
     "password": "Welcome123"
   }
   ```
5. Click "Test Connection" to verify
6. Click "Save" to store the connection

### 2. MinIO Storage Connection

1. Install the "Remote - SSH" extension
2. Open the Command Palette (Cmd/Ctrl + Shift + P)
3. Type "Remote-SSH: Connect to Host"
4. Add a new SSH host configuration:
   ```json
   {
     "name": "Local Docker",
     "host": "localhost",
     "port": 22,
     "username": "admin"
   }
   ```
5. Connect to the host
6. Open the mounted volumes:
   ```
   /Users/admin/docker_stufff/sql_stuff/staging_data
   /Users/admin/docker_stufff/sql_stuff/data_dumps
   ```

## Additional IDE Extensions

### VS Code Extensions
1. "Oracle Database Tools" - For database management
2. "Remote - SSH" - For remote file access
3. "Docker" - For container management
4. "Python" - For Python development
5. "YAML" - For Docker Compose file editing

### Cursor AI Extensions
1. "Database Tools" - For database management
2. "Docker" - For container management
3. "Python" - For Python development

## Testing Connections

### Database Connection Test
```python
import cx_Oracle

try:
    connection = cx_Oracle.connect(
        user="system",
        password="Welcome123",
        dsn="localhost:1521/FREEPDB1"
    )
    print("Successfully connected to Oracle Database")
    connection.close()
except Exception as e:
    print(f"Error connecting to Oracle Database: {e}")
```

### MinIO Connection Test
```python
from minio import Minio

try:
    client = Minio(
        "localhost:9000",
        access_key="admin",
        secret_key="admin123",
        secure=False
    )
    print("Successfully connected to MinIO")
except Exception as e:
    print(f"Error connecting to MinIO: {e}")
```

## Troubleshooting

### Database Connection Issues
1. Check if Oracle container is running:
```bash
docker ps | grep oracle
```

2. Verify database service:
```bash
docker exec sql_stuff-oracle-1 sqlplus -L system/Welcome123@//localhost:1521/FREEPDB1
```

3. Check database logs:
```bash
docker logs sql_stuff-oracle-1
```

### MinIO Connection Issues
1. Check if MinIO container is running:
```bash
docker ps | grep minio
```

2. Verify MinIO service:
```bash
curl http://localhost:9000/minio/health/live
```

3. Check MinIO logs:
```bash
docker logs sql_stuff-minio-1
```

## Security Considerations

1. Use environment variables for sensitive information:
```bash
export ORACLE_USER=system
export ORACLE_PASSWORD=Welcome123
export MINIO_ACCESS_KEY=admin
export MINIO_SECRET_KEY=admin123
```

2. Consider using SSH keys for remote connections
3. Implement proper access controls in production
4. Use secure connections (HTTPS) in production

## Best Practices

1. Always test connections before starting development
2. Keep credentials secure and never commit them to version control
3. Use connection pooling for database operations
4. Implement proper error handling for both database and storage operations
5. Monitor connection health and implement automatic reconnection logic 