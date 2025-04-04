#!/bin/bash

# Create data directory in container if it doesn't exist
docker exec sql_stuff-oracle-1 mkdir -p /opt/oracle/scripts/data

# Copy leave and survey data
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/workforce_data/leave_allowances.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/
docker cp /Users/admin/docker_stufff/sql_stuff/4_transformed_data/workforce_data/pulse_surveys.csv sql_stuff-oracle-1:/opt/oracle/scripts/data/

# Set permissions
docker exec sql_stuff-oracle-1 chown -R oracle:oinstall /opt/oracle/scripts/data
docker exec sql_stuff-oracle-1 chmod -R 755 /opt/oracle/scripts/data

echo "Leave and survey data files copied successfully!" 