#!/bin/bash

# Define employee number
EMPLOYEE=$1

# Define the base directory where the employee YAML files will be created
BASE_DIR="/home/ubuntu/cloud-browser/employee_files"

# Create a directory for the employee if it doesn't exist
EMPLOYEE_DIR="${BASE_DIR}/user${EMPLOYEE}"
mkdir -p $EMPLOYEE_DIR

# Define the base volume directory where user data will be stored
VOL_DIR="/home/ubuntu/cloud-browser/vol"

# Create a directory for the employee's persistent data if it doesn't exist
USER_VOL_DIR="${VOL_DIR}/user${EMPLOYEE}-data"
mkdir -p $USER_VOL_DIR
chmod 777 $USER_VOL_DIR

# Define file paths within the employee's folder
DEPLOYMENT_FILE="${EMPLOYEE_DIR}/user${EMPLOYEE}-deployment.yaml"
PV_FILE="${EMPLOYEE_DIR}/user${EMPLOYEE}-pv.yaml"
PVC_FILE="${EMPLOYEE_DIR}/user${EMPLOYEE}-pvc.yaml"
SERVICE_FILE="${EMPLOYEE_DIR}/user${EMPLOYEE}-service.yaml"

# Create Deployment YAML file for the employee
cat <<EOL > $DEPLOYMENT_FILE
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user${EMPLOYEE}-deployment
  labels:
    app: vnc-browser
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vnc-browser
  template:
    metadata:
      labels:
        app: vnc-browser
    spec:
      containers:
      - name: vnc-browser
        image: pardeepkaur/chrome-vnc
        ports:
        - containerPort: 5900
        volumeMounts:
        - name: chrome-data
          mountPath: /home/ubuntu/cloud-browser/vol/user${EMPLOYEE}-data
      volumes:
      - name: chrome-data
        persistentVolumeClaim:
          claimName: user${EMPLOYEE}-pvc
EOL

# Create PersistentVolume YAML file for the employee
cat <<EOL > $PV_FILE
apiVersion: v1
kind: PersistentVolume
metadata:
  name: user${EMPLOYEE}-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /home/ubuntu/cloud-browser/vol/user${EMPLOYEE}-data
EOL

# Create PersistentVolumeClaim YAML file for the employee
cat <<EOL > $PVC_FILE
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: user${EMPLOYEE}-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  volumeName: user${EMPLOYEE}-pv
EOL

# Create Service YAML file for the employee
cat <<EOL > $SERVICE_FILE
apiVersion: v1
kind: Service
metadata:
  name: user${EMPLOYEE}-vnc-browser-service
  labels:
    app: vnc-browser
spec:
  selector:
    app: vnc-browser
  ports:
  - protocol: TCP
    port: 5900
    targetPort: 5900
  type: NodePort
EOL

# Apply these YAML files to Kubernetes
kubectl apply -f $DEPLOYMENT_FILE
kubectl apply -f $PV_FILE
kubectl apply -f $PVC_FILE
kubectl apply -f $SERVICE_FILE
