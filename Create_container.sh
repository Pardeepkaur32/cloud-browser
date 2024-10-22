#!/bin/bash

# Define base directory for persistent data storage
base_data_dir="/home/ubuntu/cloud-browser/vol"  # Replace this with the actual path

# Loop to create and run containers for each user
for i in $(seq 1 3); do  # Using seq command instead of {1..3} for better compatibility
    port=$((5901 + i))  # Assign port numbers 5901, 5902, etc.
    container_name="vnc-browser-user$i"
    user_data_dir="$base_data_dir/user$i-data"  # Create a unique volume path for each user

    # Create the directory if it doesn't exist
    mkdir -p $user_data_dir

    echo "Starting container $container_name on port $port with persistent volume $user_data_dir"
    docker run -d -p $port:5900 -v $user_data_dir:/tmp/chrome-data --name $container_name vnc-browser-image
done
