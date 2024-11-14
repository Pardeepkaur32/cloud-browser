#!/bin/bash

# Loop to deploy the chart for each employee
for EMPLOYEE_ID in {1..10}; do
  echo "Deploying chart for employee ID: ${EMPLOYEE_ID}"
  helm upgrade --install vnc-browser-${EMPLOYEE_ID} . \
    --set employee.id=${EMPLOYEE_ID} \
    --set storage.size=1Gi  # Adjust storage size if needed
done

