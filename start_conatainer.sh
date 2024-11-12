#!/bin/bash

# Variables
EMPLOYEE_ID=$1
PORT=$((5900 + EMPLOYEE_ID))  # Unique port for each employee
CONTAINER_NAME="vnc-browser-employee$EMPLOYEE_ID"
USER_DATA_DIR="/home/ubuntu/cloud-browser/vol/employee${EMPLOYEE_ID}-data"

# Create the user data directory if it doesn’t exist
mkdir -p "$USER_DATA_DIR"
chmod 777 "$USER_DATA_DIR"  # Set permissions

# Check if the container is already running
if docker ps -f name="$CONTAINER_NAME" --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "Container $CONTAINER_NAME is already running."
else
    echo "Starting container $CONTAINER_NAME on port $PORT."
    docker run -d -p $PORT:5900 -v "$USER_DATA_DIR:/tmp/chrome-data" --memory="1g" --cpus="1.5" \
        -e DISPLAY=:99 \
        -e CHROME_LOG_LEVEL=DEBUG \
        --name "$CONTAINER_NAME" chrome-vnc
    echo "Container $CONTAINER_NAME started successfully on port $PORT."
fi

