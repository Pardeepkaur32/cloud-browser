#!/bin/bash

# Employee-specific ID
EMPLOYEE_ID=<unique_employee_id>

# Jenkins credentials and server details
JENKINS_USER="your_jenkins_user"
JENKINS_TOKEN="your_jenkins_api_token"
JENKINS_JOB_URL="http://<cloud-server-ip>:8080/job/Start_Chrome_Container/buildWithParameters?EMPLOYEE_ID=$EMPLOYEE_ID"

# Trigger Jenkins job to start the Docker container
curl -u $JENKINS_USER:$JENKINS_TOKEN -X POST "$JENKINS_JOB_URL"

