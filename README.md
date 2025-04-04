# SQL and Data Processing Scripts

This repository contains organized scripts for data processing, database management, and ETL operations.

## Quick Start Connection Details

### Oracle Database Connections

#### VS Code Database Client Connection (Inside code-server)
```sql
Host: sql_stuff-oracle-1
Port: 1521
Service Name: FREEPDB1
Username: system
Password: Welcome123
Connection String: system/Welcome123@//sql_stuff-oracle-1:1521/FREEPDB1
```

#### External Connection (From your local machine)
```sql
Host: localhost
Port: 1521
Service Name: FREEPDB1
Username: system
Password: Welcome123
Connection String: system/Welcome123@//localhost:1521/FREEPDB1
```

#### Application User Connection
```sql
Username: app_user
Password: app_password
Connection String (internal): app_user/app_password@//sql_stuff-oracle-1:1521/FREEPDB1
Connection String (external): app_user/app_password@//localhost:1521/FREEPDB1
```

### JDBC Connection Strings
```
Internal: jdbc:oracle:thin:@//sql_stuff-oracle-1:1521/FREEPDB1
External: jdbc:oracle:thin:@//localhost:1521/FREEPDB1
```

### MinIO Object Storage
```
Internal API Endpoint: http://minio:9000
External API Endpoint: http://localhost:9000
Web Console: http://localhost:9001
Access Key: minioadmin
Secret Key: minioadmin
Default Bucket: sql-scripts
```

### Code Server IDE
```
URL: http://localhost:8443
Password: admin123
```

## Directory Structure

- `control_files/`: SQL*Loader control files
- `python_files/`: Python transformation and utility scripts
- `sql_files/`: SQL database management scripts

## Prerequisites

- Docker and Docker Compose installed
- Git installed
- At least 4GB of free RAM
- At least 10GB of free disk space

## Getting Started

1. Start the environment:
   ```bash
   docker-compose up -d
   ```

2. Access the web IDE:
   - Open http://localhost:8443 in your browser
   - Enter password: admin123

3. Connect to Oracle Database:
   - Use the Database Client extension in VS Code
   - Use the connection details provided above
   - Test connection with: `sqlplus system/Welcome123@//sql_stuff-oracle-1:1521/FREEPDB1`

4. Access MinIO:
   - Open http://localhost:9001 for the web console
   - Use minioadmin/minioadmin to log in

## Troubleshooting

### Database Connection Issues
- Ensure the Oracle container is healthy: `docker ps`
- Check Oracle logs: `docker logs sql_stuff-oracle-1`
- Verify the database is accepting connections: `nc -zv sql_stuff-oracle-1 1521`

### MinIO Issues
- Check MinIO logs: `docker logs minio`
- Verify MinIO is accessible: `curl http://minio:9000`

### Code Server Issues
- Check logs: `docker logs code-server`
- Verify Java installation: `java -version`
- Ensure all required extensions are installed
