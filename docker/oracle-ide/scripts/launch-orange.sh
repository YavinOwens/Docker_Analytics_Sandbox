#!/bin/bash

# Navigate to the docker/oracle-ide directory
cd "$(dirname "$0")/.."

echo "=========================================="
echo "Building and launching Orange3 container..."
echo "=========================================="

# Make sure the main environment is running
docker-compose ps | grep minio > /dev/null
if [ $? -ne 0 ]; then
  echo "Main environment is not running. Starting it first..."
  docker-compose up -d minio
fi

# Build and launch the Orange3 container
docker-compose -f docker-compose.orange-standalone.yml up -d

echo ""
echo "Orange3 container is now running!"
echo ""
echo "Access the Orange3 interface at: http://localhost:6901/vnc.html"
echo "Use the password: orange"
echo ""
echo "MinIO is configured and accessible from within Orange3."
echo "When loading/saving data in Orange3, you can use the Python script"
echo "at /orange-data/minio_utils.py for MinIO integration."
echo "" 