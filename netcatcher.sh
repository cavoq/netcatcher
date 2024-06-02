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

INTERVAL="${INTERVAL:-60}"
CAPTURE_PATH="${CAPTURE_PATH:-/root/captures}"

echo "Start capturing packets and transferring them to the server every $INTERVAL seconds..."

while true; do
    current_datetime=$(date +%d-%m-%Y_%H-%M-%S)
    capture="capture_$current_datetime.pcap"

    tshark -i any -w /pcap_data/$capture &
    TSHARK_PID=$!

    sleep "$INTERVAL"

    kill "$TSHARK_PID" &>/dev/null

    sshpass -p "$SERVER_PASSWORD" scp -P "$SERVER_PORT" /pcap_data/$capture "$SERVER_USER@$SERVER_ADDRESS:$CAPTURE_PATH/$capture"

    if [ $? -eq 0 ]; then
        echo "Pcap file successfully transferred to the server."
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))

        if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
            echo "Failed to transfer pcap file after $MAX_RETRIES retries."
            exit 1
        else
            echo "Failed to transfer pcap file..."
            BACKOFF=$((2 ** $RETRY_COUNT))
            echo "Retrying in $BACKOFF seconds..."
            sleep $BACKOFF
        fi
    fi
done
