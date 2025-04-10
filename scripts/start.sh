#!/bin/bash

# Create necessary directories
mkdir -p workspace/src/python
mkdir -p workspace/sql_scripts
mkdir -p workspace/data
mkdir -p workspace/.vscode

# Create VS Code workspace settings
cat > workspace/.vscode/settings.json << EOL
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
            "host": "oracle",
            "port": "1521",
            "username": "oracle",
            "password": "oracle",
            "database": "FREE",
            "connectionTimeout": 15,
            "encrypt": false,
            "group": "Development"
        }
    ]
}
EOL

# Create a welcome file
cat > workspace/README.md << EOL
# SQL Development Workspace

Welcome to your SQL development workspace! This environment is pre-configured with:

## Features
- Oracle Database Connection
- MinIO Object Storage
- VS Code SQL Client
- Python Development Tools
- Spark Integration
- Langflow AI
- Ollama LLM
- Qdrant Vector Database

## Quick Start
1. Open the SQL Client extension (Database icon in the sidebar)
2. Your Oracle connection should be pre-configured
3. Use the File Explorer to create and manage SQL scripts
4. MinIO storage is available at http://localhost:9000
5. Spark UI is available at http://localhost:4040
6. Langflow is available at http://localhost:7860
7. Ollama API is available at http://localhost:11434
8. Qdrant is available at http://localhost:6333

## Folder Structure
- \`sql_scripts/\`: Store your SQL scripts here
- \`data/\`: Store your data files here
- \`src/python/\`: Python scripts and Spark applications

## Environment Variables
- Database connection details are pre-configured
- MinIO credentials are set up and ready to use
EOL

# Build and start the containers
echo "Building and starting containers..."
docker-compose up --build -d

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 10

# Start Spark UI
echo "Starting Spark UI..."
docker exec -d sql-ide /workspace/scripts/start_spark_ui.sh

echo "Environment is starting up..."
echo "Services will be available at:"
echo "- IDE: http://localhost:8080"
echo "- Spark UI: http://localhost:4040"
echo "- MinIO: http://localhost:9000"
echo "- Langflow: http://localhost:7860"
echo "- Ollama: http://localhost:11434"
echo "- Qdrant: http://localhost:6333"
echo "- Oracle: localhost:1521"

echo "Use 'docker-compose down' to stop all services when done"
