#!/bin/bash

# Copy files to container
docker cp transformed_data/water_utilities_data/water_utility_assets.csv sql_stuff-oracle-1:/opt/oracle/data/
docker cp load_water_utilities_data.sql sql_stuff-oracle-1:/opt/oracle/data/

# Kill any existing sessions
docker exec sql_stuff-oracle-1 bash -c 'sqlplus system/Welcome123@//localhost:1521/FREEPDB1 -S "SELECT sid, serial# FROM v$session WHERE username = '\''SYSTEM'\'' AND program LIKE '\''%sqlplus%'\'';"' | while read -r line; do
    if [[ $line =~ ([0-9]+)[[:space:]]+([0-9]+) ]]; then
        sid="${BASH_REMATCH[1]}"
        serial="${BASH_REMATCH[2]}"
        echo "Killing session $sid,$serial"
        docker exec sql_stuff-oracle-1 bash -c "sqlplus system/Welcome123@//localhost:1521/FREEPDB1 -S \"ALTER SYSTEM KILL SESSION '$sid,$serial' IMMEDIATE;\""
    fi
done

# Wait a moment for sessions to be killed
sleep 2

# Run SQL script in container
docker exec sql_stuff-oracle-1 bash -c 'sqlplus system/Welcome123@//localhost:1521/FREEPDB1 @/opt/oracle/data/load_water_utilities_data.sql' 