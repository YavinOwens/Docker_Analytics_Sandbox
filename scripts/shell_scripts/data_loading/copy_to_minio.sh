#!/bin/bash

# Change to the parent directory where all the data directories are located
cd /Users/admin/docker_stufff/sql_stuff

# Get MinIO container ID
MINIO_CONTAINER=$(docker ps -qf "name=minio")

if [ -z "$MINIO_CONTAINER" ]; then
    echo "MinIO container not found"
    exit 1
fi

# Create temporary directory in the container
docker exec $MINIO_CONTAINER mkdir -p /tmp/data_copy

# Copy directories to container's temporary directory
docker cp 1_Introduction $MINIO_CONTAINER:/tmp/data_copy/
docker cp 2_0_0_dummy_data_yaml $MINIO_CONTAINER:/tmp/data_copy/
docker cp 2_0_1_r_data $MINIO_CONTAINER:/tmp/data_copy/
docker cp 2_1_minio_copy $MINIO_CONTAINER:/tmp/data_copy/
docker cp 3_cleaned_data $MINIO_CONTAINER:/tmp/data_copy/
docker cp 4_transformed_data $MINIO_CONTAINER:/tmp/data_copy/
docker cp scripts $MINIO_CONTAINER:/tmp/data_copy/

# Set up MinIO client and create buckets with proper permissions inside the container
docker exec $MINIO_CONTAINER /bin/sh -c '
    # Fix permissions on temporary directory
    chmod -R 777 /tmp/data_copy

    # Configure MinIO client with root credentials
    mc config host add local http://localhost:9000 minioadmin minioadmin

    # Create buckets with proper permissions
    mc mb --ignore-existing local/introduction
    mc mb --ignore-existing local/dummy-data-yaml
    mc mb --ignore-existing local/r-data
    mc mb --ignore-existing local/minio-copy
    mc mb --ignore-existing local/cleaned-data
    mc mb --ignore-existing local/transformed-data
    mc mb --ignore-existing local/scripts

    # Set bucket policies to allow all operations
    for bucket in introduction dummy-data-yaml r-data minio-copy cleaned-data transformed-data scripts; do
        mc policy set public local/$bucket
    done

    # Copy files with proper permissions
    mc cp --recursive /tmp/data_copy/1_Introduction/* local/introduction/
    mc cp --recursive /tmp/data_copy/2_0_0_dummy_data_yaml/* local/dummy-data-yaml/
    mc cp --recursive /tmp/data_copy/2_0_1_r_data/* local/r-data/
    mc cp --recursive /tmp/data_copy/2_1_minio_copy/* local/minio-copy/
    mc cp --recursive /tmp/data_copy/3_cleaned_data/* local/cleaned-data/
    mc cp --recursive /tmp/data_copy/4_transformed_data/* local/transformed-data/
    mc cp --recursive /tmp/data_copy/scripts/* local/scripts/

    # Clean up temporary directory
    rm -rf /tmp/data_copy
'

echo "All directories have been copied to MinIO successfully!" 