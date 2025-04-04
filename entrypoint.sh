#!/bin/bash

# Function to wait for a service to be ready
wait_for_service() {
    local host=$1
    local port=$2
    local service=$3

    echo "Waiting for $service to be ready..."
    while ! nc -z $host $port; do
        sleep 1
    done
    echo "$service is ready!"
}

# Wait for Oracle and MinIO to be ready
wait_for_service oracle 1521 "Oracle Database"
wait_for_service minio 9000 "MinIO Storage"

echo "Installing required packages..."
# Install required packages
sudo apt-get update
sudo apt-get install -y curl libaio1 python3-pip alien netcat-traditional

echo "Installing Oracle Instant Client..."
# Install Oracle Instant Client
curl -o oracle-instantclient.deb https://download.oracle.com/otn_software/linux/instantclient/219000/oracle-instantclient-basic-21.9.0.0.0-1.x86_64.rpm
sudo alien -i oracle-instantclient.deb

echo "Installing MinIO Client..."
# Install MinIO Client
curl -O https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/

echo "Installing VS Code extensions..."
# Install VS Code extensions
code-server --install-extension ms-python.python
code-server --install-extension cweijan.vscode-database-client2

echo "Running setup script..."
# Run setup script
bash /home/coder/setup-workspace.sh

echo "Starting code-server..."
# Start code-server
exec dumb-init code-server --bind-addr 0.0.0.0:8443 --auth password /home/coder/workspace
