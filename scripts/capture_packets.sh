#!/bin/bash

SERVER_ADDRESS="${SERVER_ADDRESS:-localhost}"
SERVER_PORT="${SERVER_PORT:-22}"
SERVER_USER="${SERVER_USER:-root}"
SERVER_PASSWORD="${SERVER_PASSWORD:-root}"
MAX_RETRIES="${MAX_RETRIES:-5}"
INTERVAL="${INTERVAL:-60}"
CAPTURE_PATH="${CAPTURE_PATH:-/root/captures}"

RETRY_COUNT=0
LOG_FILE="/var/log/capture_packets.log"

log_message() {
    local message=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

check_commands() {
    for cmd in tshark sshpass scp; do
        if ! command -v "$cmd" &>/dev/null; then
            log_message "$cmd could not be found. Please install it and try again."
            exit 1
        fi
    done
}

capture_packets() {
    local current_datetime capture
    current_datetime=$(date +%d-%m-%Y_%H-%M-%S)
    capture="capture_$current_datetime.pcap"

    tshark -i any -w "/pcap_data/$capture" &
    TSHARK_PID=$!

    sleep "$INTERVAL"

    kill "$TSHARK_PID" &>/dev/null
    echo "$capture"
}

transfer_capture() {
    local capture=$1
    sshpass -p "$SERVER_PASSWORD" scp -P "$SERVER_PORT" /pcap_data/$capture "$SERVER_USER@$SERVER_ADDRESS:$CAPTURE_PATH/$capture"
}

cleanup() {
    log_message "Cleaning up..."
    [[ -n "$TSHARK_PID" ]] && kill "$TSHARK_PID" &>/dev/null
    exit 1
}

trap cleanup SIGINT SIGTERM
log_message "Starting packet capture and transfer..."
check_commands

capture=$(capture_packets)
transfer_capture "$capture"

if [ $? -eq 0 ]; then
    log_message "Pcap file successfully transferred to the server."
else
    RETRY_COUNT=$((RETRY_COUNT + 1))

    if [ "$RETRY_COUNT" -eq "$MAX_RETRIES" ]; then
        log_message "Failed to transfer pcap file after $MAX_RETRIES retries."
        exit 1
    else
        while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
            BACKOFF=$((2 ** $RETRY_COUNT))
            log_message "Failed to transfer pcap file..."
            log_message "Retrying in $BACKOFF seconds..."
            sleep "$BACKOFF"
            transfer_capture "$capture"
            if [ $? -eq 0 ]; then
                log_message "Pcap file successfully transferred to the server."
                break
            else
                RETRY_COUNT=$((RETRY_COUNT + 1))
            fi
        done
    fi
fi
