#!/bin/bash

# Validate if EMPLOYEE_ID is provided
if [ -z "$1" ]; then
    echo "Error: EMPLOYEE_ID argument is required."
    exit 1
fi

# Variables
EMPLOYEE_ID=$1
PORT=$((5900 + EMPLOYEE_ID))
CONTAINER_NAME="vnc-browser-employee$EMPLOYEE_ID"
USER_DATA_DIR="/home/ubuntu/cloud-browser/vol/employee${EMPLOYEE_ID}-data"
LOCK_FILE="/tmp/docker_container_employee_${EMPLOYEE_ID}_lock"
LOG_FILE="/var/log/docker_employee_${EMPLOYEE_ID}.log"

# Redirect output to log file
exec >> "$LOG_FILE" 2>&1

# Set up trap to remove lock file
trap 'rm -f "$LOCK_FILE"' EXIT

# Concurrency management
while [ -e "$LOCK_FILE" ]; do
    echo "$(date): Another process is managing the container for Employee ${EMPLOYEE_ID}. Waiting..."
    sleep 2
done

# Create lock file
touch "$LOCK_FILE"

# Ensure the data directory exists
if [ ! -d "$USER_DATA_DIR" ]; then
    echo "$(date): Creating directory for Employee ${EMPLOYEE_ID} at $USER_DATA_DIR"
    mkdir -p "$USER_DATA_DIR"
    chown jenkins:jenkins "$USER_DATA_DIR"
    chmod 755 "$USER_DATA_DIR"
else
    echo "$(date): Directory for Employee ${EMPLOYEE_ID} already exists at $USER_DATA_DIR"
fi

# Check if the container is already running
if docker ps -f name="$CONTAINER_NAME" --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
    echo "$(date): Container $CONTAINER_NAME is already running."
else
    # Random delay to prevent simultaneous starts
    sleep $((RANDOM % 5 + 1))

    echo "$(date): Starting container $CONTAINER_NAME on port $PORT."

    # Start the Docker container
    docker run -d -p $PORT:5900 \
        -v "$USER_DATA_DIR:/tmp/chrome-data" \
        --memory="512m" \
        --cpus="1" \
        --shm-size="256m" \
        -e DISPLAY=:99 \
        -e CHROME_LOG_LEVEL=DEBUG \
        --name "$CONTAINER_NAME" \
        pardeepkaur/chrome-vnc

    if [ $? -eq 0 ]; then
        echo "$(date): Container $CONTAINER_NAME started successfully on port $PORT."
    else
        echo "$(date): Error: Failed to start container $CONTAINER_NAME on port $PORT."
    fi
fi
