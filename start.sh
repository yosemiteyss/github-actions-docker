#!/bin/bash
set -e

# Get list of offline runners
echo "Get offline runners for: ${REPO}"
OFFLINE_RUNNER_LIST=$(curl -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${REPO}/actions/runners" | jq '[.runners[] | select(.status | contains("offline")) | {id: .id}]')

# Loop through each runner and delete it
for id in $(echo "$OFFLINE_RUNNER_LIST" | jq -r '.[] | @base64'); do
    _jq() {
        echo "${id}" | base64 --decode | jq -r "${1}"
    }

    RUNNER_ID=$(_jq '.id')
    echo "Deleting runner with ID: ${RUNNER_ID}"

    # Delete the runner
    curl -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: token ${TOKEN}" \
        "https://api.github.com/repos/${REPO}/actions/runners/${RUNNER_ID}"
done

# Get registration token
echo "Get registration token for: ${REPO}"
REG_TOKEN=$(curl -X POST -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${REPO}/actions/runners/registration-token" | jq .token --raw-output)

# Configure new runner
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
