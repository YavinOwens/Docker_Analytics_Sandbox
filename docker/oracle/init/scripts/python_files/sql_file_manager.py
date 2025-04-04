import os
import logging
from minio import Minio
from datetime import datetime
import cx_Oracle

# Configure logging
logging.basicConfig(level=logging.INFO,
                   format='%(asctime)s - %(levelname)s - %(message)s')

class SQLFileManager:
    def __init__(self):
        # MinIO configuration
        self.minio_client = Minio(
            "localhost:9000",
            access_key="admin",
            secret_key="admin123",
            secure=False
        )
        
        # Bucket names
        self.staging_bucket = "staging"
        self.dumps_bucket = "dumps"
        
        # Ensure buckets exist
        self.setup_buckets()
        
        # Oracle connection details
        self.oracle_connection = {
            'user': 'system',
            'password': 'Welcome123',
            'dsn': 'localhost:1521/FREE'
        }

    def setup_buckets(self):
        """Ensure required buckets exist"""
        for bucket in [self.staging_bucket, self.dumps_bucket]:
            if not self.minio_client.bucket_exists(bucket):
                self.minio_client.make_bucket(bucket)
                logging.info(f"Created bucket: {bucket}")

    def create_directory(self, bucket_name, directory_path):
        """Create a directory structure in the specified bucket"""
        try:
            # MinIO uses objects with trailing slash to represent directories
            if not directory_path.endswith('/'):
                directory_path += '/'
            
            # Create an empty object to represent the directory
            self.minio_client.put_object(bucket_name, directory_path, 
                                       data=b'', length=0)
            logging.info(f"Created directory in {bucket_name}: {directory_path}")
        except Exception as e:
            logging.error(f"Error creating directory {directory_path}: {str(e)}")

    def upload_sql_file(self, local_file_path, remote_path):
        """Upload SQL file to both staging and dumps buckets"""
        try:
            # Upload to staging
            self.minio_client.fput_object(self.staging_bucket, remote_path, 
                                        local_file_path)
            logging.info(f"Uploaded {local_file_path} to staging: {remote_path}")
            
            print(f"Uploaded {os.path.basename(local_file_path)} to {remote_path}")
            return True
        except Exception as e:
            logging.error(f"Error uploading file: {str(e)}")
            return False

    def list_sql_files(self, bucket_name):
        """List SQL files in the specified bucket"""
        try:
            objects = self.minio_client.list_objects(bucket_name, recursive=True)
            print(f"\nSQL files in {bucket_name}:")
            for obj in objects:
                print(f"- {obj.object_name}")
        except Exception as e:
            logging.error(f"Error listing files: {str(e)}")

    def execute_sql_file(self, sql_file_path):
        """Execute SQL file using SQL*Plus inside the Oracle container"""
        print("\nExecuting SQL file...")
        try:
            # Download the file to a temporary location
            temp_path = f"/tmp/{os.path.basename(sql_file_path)}"
            self.minio_client.fget_object(self.staging_bucket, sql_file_path, 
                                        temp_path)
            logging.info(f"Downloaded from staging: {sql_file_path} to {temp_path}")
            
            # Execute the SQL file using SQL*Plus inside the Oracle container
            cmd = f"docker exec sql_stuff-oracle-1 sqlplus system/Welcome123@//localhost:1521/FREE @{temp_path}"
            os.system(cmd)
            
            # Clean up temporary file
            os.remove(temp_path)
            
        except Exception as e:
            logging.error(f"Error executing SQL file: {str(e)}")

def main():
    manager = SQLFileManager()
    
    # Create sql_scripts directory in both buckets
    manager.create_directory("staging", "sql_scripts")
    manager.create_directory("dumps", "sql_scripts")
    
    # Get the SQL file from command line arguments
    import sys
    if len(sys.argv) > 1:
        sql_file = sys.argv[1]
        if os.path.exists(sql_file):
            manager.upload_sql_file(sql_file, f"sql_scripts/{sql_file}")
            manager.list_sql_files("staging")
            manager.execute_sql_file(f"sql_scripts/{sql_file}")
        else:
            print(f"Error: {sql_file} not found")
    else:
        # Default behavior: try verify_tables.sql, then create_financial_tables.sql, then test_connection.sql
        if os.path.exists("verify_tables.sql"):
            manager.upload_sql_file("verify_tables.sql", 
                                  "sql_scripts/verify_tables.sql")
            manager.list_sql_files("staging")
            manager.execute_sql_file("sql_scripts/verify_tables.sql")
        elif os.path.exists("create_financial_tables.sql"):
            manager.upload_sql_file("create_financial_tables.sql", 
                                  "sql_scripts/create_financial_tables.sql")
            manager.list_sql_files("staging")
            manager.execute_sql_file("sql_scripts/create_financial_tables.sql")
        elif os.path.exists("test_connection.sql"):
            manager.upload_sql_file("test_connection.sql", 
                                  "sql_scripts/test_connection.sql")
            manager.list_sql_files("staging")
            manager.execute_sql_file("sql_scripts/test_connection.sql")
        else:
            print("Error: No SQL files found")

if __name__ == "__main__":
    main()