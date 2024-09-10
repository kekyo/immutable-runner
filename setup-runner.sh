#!/bin/bash

# Check the script arguments.
if [ "$#" -ne 5 ]; then
    echo "usage: $0 <runner_name> <repo_url> <runner_token> <cache_path> [<container_version>]"
    exit 1
fi

# Save arguments into variables.
RUNNER_NAME=$1
REPO_URL=$2
RUNNER_TOKEN=$3
CACHE_PATH=$4
CONTAINER_VERSION=$5

# Setup runner container.

# Create artifacts cache directory.
echo "Creating cache directories under $CACHE_PATH..."
mkdir -p $CACHE_PATH/apt-cache
mkdir -p $CACHE_PATH/runner-cache
mkdir -p $CACHE_PATH/tool-cache
mkdir -p $CACHE_PATH/nuget-cache
mkdir -p $CACHE_PATH/npm-cache
mkdir -p $CACHE_PATH/runner-config
chown -R 15179 $CACHE_PATH

# Start podman container.
echo "Starting container $RUNNER_NAME with podman..."
podman run --name $RUNNER_NAME --rm -d \
    -v $CACHE_PATH:/data \
    -v $CACHE_PATH/apt-cache:/var/cache/apt/archives \
    -e GITHUB_RUNNER_NAME="$RUNNER_NAME" \
    -e GITHUB_URL="$REPO_URL" \
    -e GITHUB_RUNNER_TOKEN="$RUNNER_TOKEN" \
    docker.io/kekyo/immutable-runner:$CONTAINER_VERSION

# Failed starting the container:
if [ $? -ne 0 ]; then
    echo "Error: Failed to start the container."
    exit 1
fi

# Create systemd service unit.
echo "Generating systemd service file for container $RUNNER_NAME ..."
podman generate systemd \
    --name $RUNNER_NAME --new --files --restart-policy=on-success --time=2

# Move service unit file into the systemd config directory.
SERVICE_NAME=container-$RUNNER_NAME
SERVICE_FILE=${SERVICE_NAME}.service
echo "Moving generated systemd service file to /etc/systemd/system/"
sudo mv ./$SERVICE_FILE /etc/systemd/system/

# Enable container service.
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling and starting service $SERVICE_NAME ..."
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

echo "GitHub Actions Runner for $REPO_URL has been successfully set up as $SERVICE_NAME"
