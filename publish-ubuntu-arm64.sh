#!/bin/bash

# Check if correct number of arguments are passed
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <username> <token>"
  exit 1
fi

USERNAME=$1
TOKEN=$2

RUNNER_VERSION="2.321.0"
RUNNER_ARCH="linux-arm64"

# Login to GHCR
echo "Logging in to ghcr.io..."
echo "$TOKEN" | docker login ghcr.io -u "$USERNAME" --password-stdin

# Build and Publish Image
echo "Building and Publishing image..."

docker build --no-cache \
  --build-arg RUNNER_VERSION="$RUNNER_VERSION" \
  --build-arg RUNNER_ARCH="$RUNNER_ARCH" \
  -t ghcr.io/yosemiteyss/actions-ubuntu-image:latest \
  -t ghcr.io/yosemiteyss/actions-ubuntu-image:latest-arm64 \
  -t ghcr.io/yosemiteyss/actions-ubuntu-image:arm64 \
  .

docker push ghcr.io/yosemiteyss/actions-ubuntu-image --all-tags