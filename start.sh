#!/bin/bash

# Create necessary directories
mkdir -p workspace src

# Build and start the containers
docker-compose up --build -d

echo "SQL IDE is starting up..."
echo "Once ready, you can access it at: http://localhost:8080"
echo "Use Ctrl+C to stop the containers when done"
