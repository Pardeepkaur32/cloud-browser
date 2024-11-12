#!/bin/bash

# Define base directory for persistent data storage
base_data_dir="/home/ubuntu/cloud-browser/vol"  # Replace this with the actual path if different

# Function to stop and remove a container if it exists
remove_container() {
    local container_name=$1
    echo "Stopping container: $container_name"
    docker stop $container_name 2>/dev/null
    echo "Removing container: $container_name"
    docker rm $container_name 2>/dev/null
}

# Function to start a container with specific configurations
start_container() {
    local container_name=$1
    local port=$2
    local user_data_dir=$3

    # Ensure the data directory exists and has correct permissions
    mkdir -p $user_data_dir
    chmod 777 $user_data_dir  # Set permissions to avoid permission issues

    echo "Starting container $container_name on port $port with persistent volume $user_data_dir"

    # Run the Docker container with specified memory, CPU limits, and debugging options
    docker run -d -p $port:5900 -v $user_data_dir:/tmp/chrome-data --memory="1g" --cpus="1.5" \
        -e DISPLAY=:99 \
        -e CHROME_LOG_LEVEL=DEBUG \
        --name $container_name chrome-vnc

    # Check if the container started successfully
    if [ $? -eq 0 ]; then
        echo "Container $container_name started successfully on port $port."
    else
        echo "Error: Failed to start container $container_name on port $port."
    fi

    # Brief delay to avoid race conditions
    sleep 2
}

# Loop through each container, remove existing ones, and start new ones
for i in $(seq 1 3); do
    container_name="vnc-browser-user$i"
    port=$((5901 + i))  # Assign port numbers 5902, 5903, etc.
    user_data_dir="$base_data_dir/user$i-data"

    # Remove any existing container with the same name
    remove_container $container_name

    # Start a new container with the specified configurations
    start_container $container_name $port $user_data_dir
done

# List contents of each user's data directory for verification
echo "Listing contents of each user's data directory:"
for i in $(seq 1 3); do
    user_data_dir="$base_data_dir/user$i-data"
    echo "Contents of $user_data_dir:"
    ls -l $user_data_dir
    echo ""
done
