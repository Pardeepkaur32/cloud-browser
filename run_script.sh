#!/bin/bash

# Define the path to the start_container script on the server
SCRIPT_PATH="/home/ubuntu/cloud-browser/start_conatainer.sh"

# Make sure the script is executable
chmod +x $SCRIPT_PATH

# Call the start_container.sh script with the employee ID parameter
$SCRIPT_PATH $EMPLOYEE_ID

