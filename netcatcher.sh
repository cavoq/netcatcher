#!/bin/bash

source .env

SERVER_ADDRESS="${SERVER_ADDRESS:-}"
SERVER_PORT="${SERVER_PORT:-}"
SERVER_USER="${SERVER_USER:-}"
PRIVATE_KEY="${PRIVATE_KEY:-}"

if [ -z "$SERVER_ADDRESS" ]; then
  $SERVER_ADDRESS="localhost"
  exit 1
fi

if [ -z "$SERVER_PORT" ]; then
  $SERVER_PORT="22"
  exit 1
fi

if [ -z "$SERVER_USER" ]; then
  $SERVER_USER="user"
  exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
  $PRIVATE_KEY="/root/.ssh/id_rsa"
  exit 1
fi


MAX_RETRIES=5
RETRY_COUNT=0

echo "Attempting to establish reverse SSH tunnel to $SERVER_ADDRESS on port $SERVER_PORT..."

while true; do
    ssh -N -R "$SERVER_PORT:localhost:22" -o ServerAliveInterval=60 -i $PRIVATE_KEY -p "$SERVER_PORT" $SERVER_USER@"$SERVER_ADDRESS"

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
