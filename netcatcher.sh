#!/bin/bash

SERVER_ADDRESS="${SERVER_ADDRESS:-localhost}"
SERVER_PORT="${SERVER_PORT:-22}"
SERVER_USER="${SERVER_USER:-root}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"

if [ -z "$SERVER_PASSWORD" ]; then
  echo "SERVER_PASSWORD is not set."
  exit 1
fi


MAX_RETRIES=5
RETRY_COUNT=0

echo "Attempting to establish reverse SSH tunnel to $SERVER_ADDRESS on port $SERVER_PORT..."

while true; do
    sshpass -p "$SERVER_PASSWORD" ssh -R "$SERVER_PORT:localhost:22" -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -p "$SERVER_PORT" "$SERVER_USER@$SERVER_ADDRESS"

    if [ $? -eq 0 ]; then
        echo "Reverse SSH tunnel successfully established."
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))

        if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
            echo "Failed to establish reverse SSH tunnel after $MAX_RETRIES retries."
            exit 1
        else
            echo "Failed to establish reverse SSH tunnel..."
            BACKOFF=$((2 ** $RETRY_COUNT))
            echo "Retrying in $BACKOFF seconds..."
            sleep $BACKOFF
        fi
    fi
done
