#!/bin/bash

# Create data directory in container if it doesn't exist
docker exec sql_stuff-oracle-1 mkdir -p /opt/oracle/scripts/data

# Copy water utilities data
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/water_utilities_data/water_utility_assets.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/

# Copy workforce data
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/workforce_data/workforce_attendance.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/workforce_data/workforce_skills.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/workforce_data/workforce_training.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/workforce_data/workforce_scheduling.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/

# Copy industrial data
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/industrial_data/industrial_iot_data.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/industrial_data/industrial_performance.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/industrial_data/industrial_maintenance.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/industrial_data/industrial_safety.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/

# Set permissions
docker exec sql_stuff-oracle-1 chown -R oracle:oinstall /opt/oracle/scripts/data
docker exec sql_stuff-oracle-1 chmod -R 755 /opt/oracle/scripts/data

echo "Data files copied successfully!" 