#!/bin/bash

# Create workspace directory structure
mkdir -p /home/coder/workspace/sql_scripts
mkdir -p /home/coder/workspace/data
mkdir -p /home/coder/workspace/.vscode

# Create VS Code workspace settings
cat > /home/coder/workspace/.vscode/settings.json << EOL
{
    "database-client.telemetry.enabled": false,
    "database-client.showFilter": true,
    "database-client.connectionSaving": true,
    "database-client.highlightMatches": true,
    "database-client.defaultDatabase": "oracle",
    "database-client.connections": [
        {
            "name": "Oracle DB",
            "type": "oracle",
            "host": "\${env:DB_HOST}",
            "port": "\${env:DB_PORT}",
            "username": "\${env:DB_USER}",
            "password": "\${env:DB_PASSWORD}",
            "database": "\${env:DB_SERVICE}",
            "connectionTimeout": 15,
            "encrypt": false,
            "group": "Development"
        }
    ]
}
EOL

# Create MinIO configuration
mc alias set local http://minio:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY}
mc mb local/sql-scripts --ignore-existing

# Create a welcome file
cat > /home/coder/workspace/README.md << EOL
# SQL Development Workspace

Welcome to your SQL development workspace! This environment is pre-configured with:

## Features
- Oracle Database Connection
- MinIO Object Storage
- VS Code SQL Client
- Python Development Tools

## Quick Start
1. Open the SQL Client extension (Database icon in the sidebar)
2. Your Oracle connection should be pre-configured
3. Use the File Explorer to create and manage SQL scripts
4. MinIO storage is available at http://minio:9000

## Folder Structure
- \`sql_scripts/\`: Store your SQL scripts here
- \`data/\`: Store your data files here

## Environment Variables
- Database connection details are pre-configured
- MinIO credentials are set up and ready to use
EOL

# Set permissions
chmod +x /home/coder/workspace/setup-workspace.sh
chown -R coder:coder /home/coder/workspace
