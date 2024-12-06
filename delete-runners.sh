#!/bin/bash
set -e

# Get list of offline runners
echo "Get offline runners for: ${REPO}"
RUNNER_LIST=$(curl -H "Authorization: token ${TOKEN}" -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/${REPO}/actions/runners" | jq '[.runners[] | select(.status | contains("offline")) | {id: .id}]')

# Loop through each runner and delete it
for id in $(echo "$RUNNER_LIST" | jq -r '.[] | @base64'); do
    _jq() {
        echo "${id}" | base64 --decode | jq -r "${1}"
    }

    RUNNER_ID=$(_jq '.id')
    echo "Deleting runner with ID: ${RUNNER_ID}"

    # Delete the runner
    curl -X DELETE -H "Accept: application/vnd.github+json" -H "Authorization: token ${TOKEN}" \
        "https://api.github.com/repos/${REPO}/actions/runners/${RUNNER_ID}"
done