FROM ubuntu:latest

# Install required package.
RUN apt-get update && \
    apt-get install -y curl ca-certificates jq git sudo libicu-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create runner user and home directory.
RUN useradd -u 15179 -m -s /bin/bash runner && \
    echo "runner ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/runner

# Set runner home directory.
ENV RUNNER_HOME=/home/runner/actions-runner
RUN mkdir -p ${RUNNER_HOME} && chown runner ${RUNNER_HOME}

# RUNNER_RUNTIME_CACHE
ENV RUNNER_RUNTIME_CACHE=/data/runner-cache

# RUNNER_TOOL_CACHE (tool-cache/setup-dotnet)
ENV RUNNER_TOOL_CACHE=/data/tool-cache

# NUGET_PACKAGES
ENV NUGET_PACKAGES=/data/nuget-cache

# NPM_CONFIG_CACHE
ENV NPM_CONFIG_CACHE=/data/npm-cache

WORKDIR ${RUNNER_HOME}

# Copy entry point script.
COPY __ep.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh

# Change runner user.
USER runner

ENTRYPOINT ["./entrypoint.sh"]
