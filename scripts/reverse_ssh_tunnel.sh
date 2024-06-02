#!/bin/bash

SERVER_ADDRESS="${SERVER_ADDRESS:-localhost}"
SERVER_PORT="${SERVER_PORT:-22}"
SERVER_USER="${SERVER_USER:-root}"
SERVER_PASSWORD="${SERVER_PASSWORD:-root}"
MAX_RETRIES="${MAX_RETRIES:-5}"

LOG_FILE="/var/log/reverse_ssh_tunnel.log"
RETRY_COUNT=0

log_message() {
    local message=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

check_tunnel() {
    if sshpass -p "$SERVER_PASSWORD" ssh -o StrictHostKeyChecking=no -p "$SERVER_PORT" "$SERVER_USER@$SERVER_ADDRESS" "ss -ntp | grep -q 'LISTEN.*:$SERVER_PORT'"; then
        log_message "Reverse SSH tunnel is already established."
        return 0
    else
        log_message "Reverse SSH tunnel is not established."
        return 1
    fi
}

establish_tunnel() {
    local RETRY_COUNT=0

    log_message "Attempting to establish reverse SSH tunnel to $SERVER_ADDRESS on port $SERVER_PORT..."

    while true; do
        sshpass -p "$SERVER_PASSWORD" ssh -R "$SERVER_PORT:localhost:22" -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -p "$SERVER_PORT" "$SERVER_USER@$SERVER_ADDRESS" |& tee -a "$LOG_FILE"

        if [ "${PIPESTATUS[0]}" -eq 0 ]; then
            log_message "Reverse SSH tunnel successfully established."
            break
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))

            if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
                log_message "Failed to establish reverse SSH tunnel after $MAX_RETRIES retries."
                exit 1
            else
                log_message "Failed to establish reverse SSH tunnel. Retrying..."
                BACKOFF=$((2 ** $RETRY_COUNT))
                log_message "Retrying in $BACKOFF seconds..."
                sleep $BACKOFF
            fi
        fi
    done
}

main() {
    check_tunnel
    if [ $? -eq 1 ]; then
        establish_tunnel
    fi
}

main
