#!/bin/bash

# Get the Oracle container ID
CONTAINER_ID=$(docker ps -qf "name=oracle")

if [ -z "$CONTAINER_ID" ]; then
    echo "Error: Oracle container not found"
    exit 1
fi

# Create data directory in the container
docker exec $CONTAINER_ID mkdir -p /opt/oracle/data

# Copy files from industrial_data
docker cp industrial_data/water_utility_assets.csv $CONTAINER_ID:/opt/oracle/data/
docker cp industrial_data/water_utilities_work_orders.csv $CONTAINER_ID:/opt/oracle/data/

# Copy files from water_utilities_metrics
docker cp water_utilities_metrics/ofwat_results.csv $CONTAINER_ID:/opt/oracle/data/
docker cp water_utilities_metrics/capex_projects.csv $CONTAINER_ID:/opt/oracle/data/
docker cp water_utilities_metrics/pulse_surveys.csv $CONTAINER_ID:/opt/oracle/data/

# Copy files from workforce_data
docker cp workforce_data/employees.csv $CONTAINER_ID:/opt/oracle/data/
docker cp workforce_data/performance_reviews.csv $CONTAINER_ID:/opt/oracle/data/
docker cp workforce_data/leave_records.csv $CONTAINER_ID:/opt/oracle/data/
docker cp workforce_data/training_records.csv $CONTAINER_ID:/opt/oracle/data/

# Set permissions
docker exec $CONTAINER_ID chown -R oracle:oinstall /opt/oracle/data
docker exec $CONTAINER_ID chmod -R 755 /opt/oracle/data

echo "Files copied successfully to Oracle container" 