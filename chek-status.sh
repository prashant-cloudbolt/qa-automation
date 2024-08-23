#!/bin/bash

workflow_list=$(gh run list --repo prashant-cloudbolt/qa-automation --workflow=maven.yml --branch=multi_tenant_stage --limit=1 --json databaseId)
echo $workflow_list

# Use jq directly with the output string
run_id=$(echo "$workflow_list" | jq -r '.[0].databaseId')
echo "run_id=$run_id"

status=""
while [ "$status" != "completed" ]; do
status=$(gh api "/repos/prashant-cloudbolt/qa-automation/actions/runs/$run_id" --jq '.status')
echo "Current status: $status"
if [ "$status" == "completed" ]; then
    conclusion=$(gh api "/repos/prashant-cloudbolt/qa-automation/actions/runs/$run_id" --jq '.conclusion')
    echo "Final conclusion: $conclusion"
    if [ "$conclusion" != "success" ]; then
    echo "Target workflow failed. Failing source workflow."
    exit 1
    fi
fi
sleep 10
done