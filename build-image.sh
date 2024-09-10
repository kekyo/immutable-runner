#!/bin/sh

#dotnet tool install -g rv-cli

export VERSION=`rv .`

# Build
sed "s/@{VERSION}/${VERSION}/g" < entrypoint.sh > __ep.sh
podman build -t kekyo/immutable-runner:${VERSION} .

# Apply latest tag.
podman tag kekyo/immutable-runner:${VERSION} kekyo/immutable-runner:latest

# Push
podman push kekyo/immutable-runner:${VERSION}
podman push kekyo/immutable-runner:latest
