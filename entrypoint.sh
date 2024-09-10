#!/bin/bash

set -x

echo "immutable-runner [@{VERSION}]"
echo "Copyright (c) Kouji Matsui"
echo "https://github.com/kekyo/immutable-runner/"
echo ""

# Check required variables.
if [ -z "$GITHUB_RUNNER_NAME" ] || [ -z "$GITHUB_URL" ] || [ -z "$GITHUB_RUNNER_TOKEN" ]; then
  echo "error: GITHUB_RUNNER_NAME, GITHUB_URL and GITHUB_RUNNER_TOKEN are required."
  exit 1
fi

# Fetch runner runtime version from GitHub.
#LATEST_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name' | sed 's/^v//')
LATEST_VERSION=$(curl -s https://github.com/actions/runner/releases | grep -oP 'releases/tag/v\K[0-9.]+' | head -n 1)

# Required download runner runtime:
if [ ! -d "./bin" ]; then
  RUNNER_RUNTIME_ARCHIVE_PATH=${RUNNER_RUNTIME_CACHE}/actions-runner-linux-x64-${LATEST_VERSION}.tar.gz
  if [ ! -f "${RUNNER_RUNTIME_ARCHIVE_PATH}" ]; then
    RUNNER_RUNTIME_ARCHIVE_URL=https://github.com/actions/runner/releases/download/v${LATEST_VERSION}/actions-runner-linux-x64-${LATEST_VERSION}.tar.gz
    echo "Downloading GitHub runner: $RUNNER_RUNTIME_ARCHIVE_URL"
    curl -o ${RUNNER_RUNTIME_ARCHIVE_PATH} -L ${RUNNER_RUNTIME_ARCHIVE_URL}
  fi
  echo "Setting up GitHub runner: $RUNNER_RUNTIME_ARCHIVE_PATH"
  tar -zxf ${RUNNER_RUNTIME_ARCHIVE_PATH}
fi

# Already configured runner runtime:
if [ -f "/data/runner-config/$GITHUB_RUNNER_NAME" ]; then
  echo "Runner already configured. Skipping registration."
  cp /data/runner-config/$GITHUB_RUNNER_NAME .
else
  echo "Configuring the GitHub runner..."
  ./config.sh --url $GITHUB_URL --token $GITHUB_RUNNER_TOKEN --unattended --replace --name $GITHUB_RUNNER_NAME
  if [ ! -f ".runner" ]; then
    exit $?
  fi
  cp .runner /data/runner-config/$GITHUB_RUNNER_NAME
fi

# Run runner at once.
./run.sh --once

# Copy back current configuration.
cp .runner /data/runner-config/$GITHUB_RUNNER_NAME
