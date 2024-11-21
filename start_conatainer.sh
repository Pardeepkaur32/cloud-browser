#!/bin/bash

# Validate if EMPLOYEE_ID is provided
if [ -z "$1" ]; then
    echo "Error: EMPLOYEE_ID argument is required."
    exit 1
fi

# Variables
EMPLOYEE_ID=$1
PORT=$((5900 + EMPLOYEE_ID))  # Unique port for each employee
CONTAINER_NAME="vnc-browser-employee$EMPLOYEE_ID"
VOLUME_DIR="/home/ubuntu/cloud-browser/vol/user${EMPLOYEE_ID}"  # Volume directory for the user
LOCK_FILE="/tmp/docker_container_employee_${EMPLOYEE_ID}_lock"

# Create the volume directory if it doesn't exist
if [ ! -d "$VOLUME_DIR" ]; then
    echo "Creating directory for Employee ${EMPLOYEE_ID} at $VOLUME_DIR"
    mkdir -p "$VOLUME_DIR"
    chmod 777 "$VOLUME_DIR"
else
    echo "Directory for Employee ${EMPLOYEE_ID} already exists at $VOLUME_DIR"
fi

# Wait if another process is handling the same employee's container
while [ -e "$LOCK_FILE" ]; do
    echo "Another process is managing the container for Employee ${EMPLOYEE_ID}. Waiting..."
    sleep 2
done

# Create a unique lock file to prevent simultaneous container starts
touch "$LOCK_FILE"

# Check if the container is already running
if docker ps -f name="$CONTAINER_NAME" --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "Container $CONTAINER_NAME is already running."
else
    # Introduce a random delay to prevent simultaneous starts
    sleep $((RANDOM % 5 + 1))

    echo "Starting container $CONTAINER_NAME on port $PORT."

    # Start the Docker container with a volume mount to persist employee-specific data
    docker run -d -p $PORT:5900 \
        -v "$VOLUME_DIR:/tmp/chrome-data" \  # Add volume for persistent data
        --memory="512m" \
        --cpus="1" \
        --shm-size="256m" \
        -e DISPLAY=:99 \
        -e CHROME_LOG_LEVEL=DEBUG \
        --name "$CONTAINER_NAME" \
        chrome-vnc

    if [ $? -eq 0 ]; then
        echo "Container $CONTAINER_NAME started successfully on port $PORT."
    else
        echo "Error: Failed to start container $CONTAINER_NAME on port $PORT."
    fi
fi

# Remove the lock file after completing the operation
rm -f "$LOCK_FILE"
