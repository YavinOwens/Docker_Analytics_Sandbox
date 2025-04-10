import os
import cx_Oracle
from minio import Minio
import sys

def test_oracle_connection():
    try:
        # Get Oracle connection details from environment variables
        host = os.environ.get('ORACLE_HOST', 'oracle')
        port = os.environ.get('ORACLE_PORT', '1521')
        service = os.environ.get('ORACLE_SERVICE', 'ORCLPDB1')
        user = os.environ.get('ORACLE_USER', 'system')
        password = os.environ.get('ORACLE_PASSWORD', 'oracle')

        # Create connection string
        dsn = cx_Oracle.makedsn(host, port, service_name=service)

        # Connect to Oracle
        connection = cx_Oracle.connect(user, password, dsn)
        print("✅ Oracle connection successful!")

        # Test a simple query
        cursor = connection.cursor()
        cursor.execute("SELECT SYSDATE FROM DUAL")
        result = cursor.fetchone()
        print(f"Oracle server time: {result[0]}")

        cursor.close()
        connection.close()
        return True
    except Exception as e:
        print(f"❌ Oracle connection failed: {str(e)}")
        return False

def test_minio_connection():
    try:
        # Get MinIO connection details from environment variables
        endpoint = os.environ.get('MINIO_ENDPOINT', 'minio:9000')
        access_key = os.environ.get('MINIO_ACCESS_KEY', 'minioadmin')
        secret_key = os.environ.get('MINIO_SECRET_KEY', 'minioadmin')

        # Create MinIO client
        client = Minio(
            endpoint,
            access_key=access_key,
            secret_key=secret_key,
            secure=False  # Set to True if using HTTPS
        )

        # Test bucket operations
        bucket_name = "sql-scripts"

        # Check if bucket exists, create if not
        if not client.bucket_exists(bucket_name):
            client.make_bucket(bucket_name)
            print(f"✅ Created MinIO bucket: {bucket_name}")
        else:
            print(f"✅ MinIO bucket exists: {bucket_name}")

        # List buckets to verify connection
        buckets = client.list_buckets()
        print("Available MinIO buckets:")
        for bucket in buckets:
            print(f"  - {bucket.name}")

        return True
    except Exception as e:
        print(f"❌ MinIO connection failed: {str(e)}")
        return False

if __name__ == "__main__":
    print("Testing connections...")
    oracle_success = test_oracle_connection()
    minio_success = test_minio_connection()

    if oracle_success and minio_success:
        print("\n✅ All connections successful!")
        sys.exit(0)
    else:
        print("\n❌ Some connections failed!")
        sys.exit(1)
