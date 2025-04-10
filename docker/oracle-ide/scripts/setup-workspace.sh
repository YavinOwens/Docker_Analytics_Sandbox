#!/bin/bash

# Create workspace directories if they don't exist
mkdir -p /workspace/src
mkdir -p /workspace/connector
mkdir -p /workspace/sql_files
mkdir -p /workspace/python_files

# Set permissions
chmod -R 755 /workspace

# Create a test PySpark script if it doesn't exist
if [ ! -f /workspace/src/python/spark_test.py ]; then
    mkdir -p /workspace/src/python
    cat > /workspace/src/python/spark_test.py << 'EOL'
import findspark
findspark.init()

from pyspark.sql import SparkSession
import time
import os

print("Creating Spark session...")
print(f"SPARK_HOME: {os.environ.get('SPARK_HOME')}")
print(f"JAVA_HOME: {os.environ.get('JAVA_HOME')}")

# Create a Spark session
spark = SparkSession.builder \
    .appName("SparkUITest") \
    .config("spark.ui.port", "4040") \
    .config("spark.driver.bindAddress", "0.0.0.0") \
    .config("spark.driver.host", "0.0.0.0") \
    .master("local[*]") \
    .getOrCreate()

print("Spark session created")
print(f"Spark UI URL: http://localhost:4040")

# Create some test data
data = [("Alice", 1), ("Bob", 2), ("Charlie", 3)]
df = spark.createDataFrame(data, ["Name", "Age"])
df.show()

# Keep the application running to keep UI available
print("Keeping application alive for 10 minutes to allow UI access...")
print("You can access the Spark UI at http://localhost:4040")
time.sleep(600)
EOL
    chmod +x /workspace/src/python/spark_test.py
fi

# Create a launcher script
cat > /home/developer/start_spark_ui.sh << 'EOL'
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
EOL
chmod +x /home/developer/start_spark_ui.sh
