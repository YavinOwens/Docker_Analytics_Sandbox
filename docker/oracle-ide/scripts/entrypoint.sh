#!/bin/bash

# Start Spark master and worker in the background
echo "Starting Spark Master and Worker..."
$SPARK_HOME/sbin/start-master.sh
$SPARK_HOME/sbin/start-worker.sh spark://0.0.0.0:7077

# Start VS Code server
code-server --install-extension \
    ms-python.python \
    ms-python.vscode-pylance \
    ms-azuretools.vscode-docker \
    ms-vscode-remote.remote-containers \
    eamodio.gitlens \
    redhat.vscode-yaml \
    ms-vscode.powershell \
    ms-vscode-remote.remote-ssh

# Run setup script if it exists
if [ -f /home/developer/setup-workspace.sh ]; then
    /home/developer/setup-workspace.sh
fi

# Start VS Code server
exec code-server --bind-addr 0.0.0.0:8080 --auth none
