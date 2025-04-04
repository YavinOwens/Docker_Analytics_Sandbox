#!/bin/bash

# Copy files to container
docker cp transformed_data/workforce_data/workforce_performance.csv sql_stuff-oracle-1:/opt/oracle/data/
docker cp load_workforce_performance.sql sql_stuff-oracle-1:/opt/oracle/data/

# Run SQL script in container
docker exec sql_stuff-oracle-1 bash -c 'sqlplus system/Welcome123@//localhost:1521/FREEPDB1 @/opt/oracle/data/load_workforce_performance.sql' 