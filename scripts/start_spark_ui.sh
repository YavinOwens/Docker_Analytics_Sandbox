#!/bin/bash

# This script starts a PySpark session that keeps the UI running
echo "Starting PySpark session with UI at http://localhost:4040"
cd /workspace

# Redirect all output to a log file
exec > /tmp/spark_ui.log 2>&1

# Run the Spark test script in the background
python3 /workspace/src/python/spark_test.py &

echo "Spark UI started - check http://localhost:4040"
echo "Log file at /tmp/spark_ui.log"
