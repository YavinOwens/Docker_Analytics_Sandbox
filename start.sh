#!/bin/bash

# Start supervisord in the foreground
supervisord -n -c /etc/supervisor/conf.d/supervisord.conf &

# Run the test connections script
echo "Running connection tests..."
python test_connections.py
