#!/bin/bash
set -e

# Get registration token
echo "Get registration token for: ${REPO}"
REG_TOKEN=$(curl -X POST -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${REPO}/actions/runners/registration-token" | jq .token --raw-output)

# Configure runner
echo "Start configure runner..."
cd /home/runner/actions-runner
./config.sh --url "https://github.com/${REPO}" --token "${REG_TOKEN}"

# Update docker socket ownership
sudo chown root:docker /var/run/docker.sock

# Setup cleanup handler
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "${REG_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start runner
./run.sh & wait $!
