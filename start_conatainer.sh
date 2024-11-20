#!/bin/bash

# Variables
EMPLOYEE_ID=$1
PORT=$((5900 + EMPLOYEE_ID))  # Unique port for each employee
CONTAINER_NAME="vnc-browser-employee$EMPLOYEE_ID"
USER_DATA_DIR="/home/ubuntu/cloud-browser/vol/employee${EMPLOYEE_ID}-data"
LOCK_FILE="/tmp/docker_container_employee_${EMPLOYEE_ID}_lock"

# Wait if another process is handling the same employee's container
while [ -e "$LOCK_FILE" ]; do
    echo "Another process is managing the container for Employee ${EMPLOYEE_ID}. Waiting..."
    sleep 2
done

# Create a unique lock file
touch "$LOCK_FILE"

# Ensure the user data directory exists in the host's /vol folder
mkdir -p "$USER_DATA_DIR"
chmod 777 "$USER_DATA_DIR"

# Check if the container is already running
if docker ps -f name="$CONTAINER_NAME" --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "Container $CONTAINER_NAME is already running."
else
    # Introduce a random delay to prevent simultaneous starts
    sleep $((RANDOM % 5 + 1))

    echo "Starting container $CONTAINER_NAME on port $PORT."
    docker run -d -p $PORT:5900 \
        -v "$USER_DATA_DIR:/tmp/chrome-data" \ 
        --memory="512m" --cpus="1" --shm-size="256m" \
        -e DISPLAY=:99 -e CHROME_LOG_LEVEL=DEBUG \
        --name "$CONTAINER_NAME" chrome-vnc

    if [ $? -eq 0 ]; then
        echo "Container $CONTAINER_NAME started successfully on port $PORT."
    else
        echo "Error: Failed to start container $CONTAINER_NAME on port $PORT."
    fi
fi

# Remove lock after starting
rm -f "$LOCK_FILE"
