#!/bin/bash

set -e

REGION="us-west-2"

deploy_new_task() {
  NEW_TASK=$(
        aws ecs update-service \
        --cluster $CLUSTER_NAME \
        --service $SERVICE_NAME \
        --region $REGION \
        --force-new-deployment
        )
}

get_service() {
  SERVICE=$(
        aws ecs describe-services \
        --cluster $CLUSTER_NAME \
        --services $SERVICE_NAME \
        --region $REGION \
        | jq .services[].events[0].message
        )
}

main() {
  echo "Deploying new task...Please wait"
  deploy_new_task
  sleep 30
  COUNT=1
  while [[ "$COUNT" -lt 30 ]]; do
    get_service
    if [[ $SERVICE = *"has reached a steady state"* ]]; then
      echo $SERVICE
      echo "Task deployed successfully"
      break
    else
      echo "Waiting for new task(s) to deploy and old tasks to drain connections..."
      echo "Current deploy status is: $SERVICE"
      COUNT=$((COUNT + 1))
      sleep 30
    fi
  done
}

main
