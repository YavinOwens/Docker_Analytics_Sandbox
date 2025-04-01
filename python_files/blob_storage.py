import os
from minio import Minio
from minio.error import S3Error
import logging
from pathlib import Path
import json
from datetime import datetime
from io import BytesIO
from minio.commonconfig import CopySource

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('blob_storage.log'),
        logging.StreamHandler()
    ]
)

class BlobStorage:
    def __init__(self):
        # Configure logging
        self.logger = logging.getLogger(__name__)
        
        # Initialize MinIO client
        self.client = Minio(
            "localhost:9000",
            access_key="admin",
            secret_key="admin123",
            secure=False
        )
        
        # Ensure buckets exist
        self.setup_buckets()
        
    def setup_buckets(self):
        """Create staging and dumps buckets if they don't exist."""
        for bucket in ["staging", "dumps"]:
            try:
                if not self.client.bucket_exists(bucket):
                    self.client.make_bucket(bucket)
                    self.logger.info(f"Created bucket: {bucket}")
            except S3Error as e:
                self.logger.error(f"Error creating bucket {bucket}: {e}")
                raise
    
    def create_staging_directory(self, directory_path):
        """Create a directory in the staging bucket."""
        try:
            # In S3/MinIO, directories are represented by empty objects with trailing slashes
            if not directory_path.endswith('/'):
                directory_path += '/'
            
            # Create an empty object to represent the directory
            self.client.put_object(
                bucket_name="staging",
                object_name=directory_path,
                data=BytesIO(b""),
                length=0
            )
            self.logger.info(f"Created directory in staging: {directory_path}")
        except S3Error as e:
            self.logger.error(f"Error creating directory in staging: {e}")
            raise

    def create_dumps_directory(self, directory_path):
        """Create a directory in the dumps bucket."""
        try:
            # In S3/MinIO, directories are represented by empty objects with trailing slashes
            if not directory_path.endswith('/'):
                directory_path += '/'
            
            # Create an empty object to represent the directory
            self.client.put_object(
                bucket_name="dumps",
                object_name=directory_path,
                data=BytesIO(b""),
                length=0
            )
            self.logger.info(f"Created directory in dumps: {directory_path}")
        except S3Error as e:
            self.logger.error(f"Error creating directory in dumps: {e}")
            raise

    def upload_to_staging(self, local_file_path, staging_path):
        """Upload a file to the staging bucket."""
        try:
            self.client.fput_object(
                "staging", staging_path, local_file_path
            )
            self.logger.info(f"Uploaded {local_file_path} to staging: {staging_path}")
        except S3Error as e:
            self.logger.error(f"Error uploading to staging: {e}")
            raise

    def upload_to_dumps(self, local_file_path, dumps_path):
        """Upload a file to the dumps bucket."""
        try:
            self.client.fput_object(
                "dumps", dumps_path, local_file_path
            )
            self.logger.info(f"Uploaded {local_file_path} to dumps: {dumps_path}")
        except S3Error as e:
            self.logger.error(f"Error uploading to dumps: {e}")
            raise

    def download_from_staging(self, staging_path, local_file_path):
        """Download a file from the staging bucket."""
        try:
            self.client.fget_object(
                "staging", staging_path, local_file_path
            )
            self.logger.info(f"Downloaded from staging: {staging_path} to {local_file_path}")
        except S3Error as e:
            self.logger.error(f"Error downloading from staging: {e}")
            raise

    def download_from_dumps(self, dumps_path, local_file_path):
        """Download a file from the dumps bucket."""
        try:
            self.client.fget_object(
                "dumps", dumps_path, local_file_path
            )
            self.logger.info(f"Downloaded from dumps: {dumps_path} to {local_file_path}")
        except S3Error as e:
            self.logger.error(f"Error downloading from dumps: {e}")
            raise

    def list_staging_files(self, prefix=""):
        """List all files in the staging bucket."""
        try:
            objects = self.client.list_objects("staging", prefix=prefix, recursive=True)
            return [obj.object_name for obj in objects]
        except S3Error as e:
            self.logger.error(f"Error listing staging files: {e}")
            raise

    def list_dumps_files(self, prefix=""):
        """List all files in the dumps bucket."""
        try:
            objects = self.client.list_objects("dumps", prefix=prefix, recursive=True)
            return [obj.object_name for obj in objects]
        except S3Error as e:
            self.logger.error(f"Error listing dumps files: {e}")
            raise

    def remove_from_staging(self, staging_path):
        """Remove a file from the staging bucket."""
        try:
            self.client.remove_object("staging", staging_path)
            self.logger.info(f"Removed from staging: {staging_path}")
        except S3Error as e:
            self.logger.error(f"Error removing from staging: {e}")
            raise

    def remove_from_dumps(self, dumps_path):
        """Remove a file from the dumps bucket."""
        try:
            self.client.remove_object("dumps", dumps_path)
            self.logger.info(f"Removed from dumps: {dumps_path}")
        except S3Error as e:
            self.logger.error(f"Error removing from dumps: {e}")
            raise

    def archive_to_dumps(self, staging_path):
        """Move a file from staging to dumps with timestamp."""
        try:
            # Generate timestamped path for dumps
            filename = os.path.basename(staging_path)
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            dumps_path = f"archived_data/{timestamp}_{filename}"
            
            # Create CopySource object
            copy_source = CopySource("staging", staging_path)
            
            # Copy to dumps
            self.client.copy_object(
                "dumps",
                dumps_path,
                copy_source
            )
            
            # Remove from staging
            self.remove_from_staging(staging_path)
            
            self.logger.info(f"Archived {staging_path} to dumps: {dumps_path}")
            return dumps_path
        except S3Error as e:
            self.logger.error(f"Error archiving to dumps: {e}")
            raise

    def get_file_info(self, bucket, file_path):
        """Get information about a file."""
        try:
            obj = self.client.stat_object(bucket, file_path)
            return {
                'size': obj.size,
                'last_modified': obj.last_modified,
                'content_type': obj.content_type,
                'etag': obj.etag
            }
        except S3Error as e:
            self.logger.error(f"Error getting file info: {e}")
            raise

def main():
    """Example usage of the BlobStorage class"""
    try:
        # Initialize blob storage
        blob_storage = BlobStorage()

        # Create some example directories
        blob_storage.create_staging_directory("raw_data")
        blob_storage.create_staging_directory("processed_data")
        blob_storage.create_dumps_directory("archived_data")

        # Example: Upload a file to staging
        test_file = "test_data.csv"
        if os.path.exists(test_file):
            blob_storage.upload_to_staging(test_file, "raw_data/test_data.csv")

        # List files in staging
        staging_files = blob_storage.list_staging_files()
        logging.info(f"Files in staging: {staging_files}")

        # Example: Archive a file to dumps
        if staging_files:
            blob_storage.archive_to_dumps(staging_files[0])

        # List files in dumps
        dumps_files = blob_storage.list_dumps_files()
        logging.info(f"Files in dumps: {dumps_files}")

    except Exception as e:
        logging.error(f"Error in main: {e}")
        raise

if __name__ == "__main__":
    main() 