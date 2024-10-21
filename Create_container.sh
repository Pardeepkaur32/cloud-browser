#!/bin/bash

# Number of users
num_users=5  # Change this number based on how many containers you want to create

for i in $(seq 1 $num_users); do
    port=$((5900 + i))  # Assign ports 5901, 5902, etc.
    container_name="chrome-vnc-container-user$i"
    volume_path="/home/ubuntu/user$i-data"  # Path on the host for persistent data

    # Create the directory if it doesn't exist
    mkdir -p $volume_path

    echo "Creating container $container_name on port $port with persistent volume $volume_path"
    
    # Run the Docker container with a persistent volume for each user
    docker run -d -p $port:5900 -v $volume_path:/tmp/chrome-data --name $container_name chrome-vnc
done
