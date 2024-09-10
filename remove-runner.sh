#!/bin/bash

# Check the script arguments.
if [ "$#" -ne 1 ]; then
    echo "usage: $0 <runner-name>"
    exit 1
fi

# Save arguments into variables.
RUNNER_NAME=$1
SERVICE_NAME=container-$RUNNER_NAME

echo "Stopping and removing systemd service for $RUNNER_NAME ..."

# Step 1: Stop systemd service and disabling.
if systemctl is-active --quiet $SERVICE_NAME; then
    echo "Stopping systemd service..."
    sudo systemctl stop $SERVICE_NAME || echo "Warning: Failed to stop service, it might not be running."
fi

if systemctl is-enabled --quiet $SERVICE_NAME; then
    echo "Disabling systemd service..."
    sudo systemctl disable $SERVICE_NAME || echo "Warning: Failed to disable service, it might not be enabled."
fi

# Step 2: Delete systemd unit file.
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
if [ -f "$SERVICE_FILE" ]; then
    echo "Removing systemd service file..."
    sudo rm -f "$SERVICE_FILE" || echo "Warning: Failed to remove service file."
else
    echo "Service file not found, skipping."
fi

# Step 3: Reload systemd.
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

# Step 4: Delete the container.
echo "Removing Podman container $RUNNER_NAME ..."
podman rm -f $RUNNER_NAME || echo "Warning: Failed to remove container, it might not be running."

echo "Cleanup for $RUNNER_NAME completed."
