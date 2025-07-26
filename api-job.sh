#!/bin/bash

consumer_id=$(cat /etc/secrets/consumer_id-2.txt)
key_version="1"
private_key_file="/etc/secrets/private_key1.txt"

generate_signature() {
    local consumer_id="$1"
    local timestamp="$2"
    local key_version="$3"
    local private_key_file="$4"

    # No trailing newline after last value
    to_sign="${consumer_id}\n${timestamp}\n${key_version}"

    echo -e "$to_sign" | openssl dgst -sha256 -sign "$private_key_file" | base64 -w 0
}

log() {
    echo "$(date): $1"
}

if [ -z "${exitCode}" ]; then
    exitCode=0
fi

callApiEndpoint() {
    log "====== API Call Job Started ======"

    local timestamp=$(($(date +%s%N) / 1000000))  # milliseconds
    local signature=$(generate_signature "$consumer_id" "$timestamp" "$key_version" "$private_key_file")

    curl -v --location --request POST 'http://104.154.182.195/api/process' \
               --header "RT_SEC.KEY_VERSION: $key_version" \
               --header "RT_CONSUMER.INTIMESTAMP: $timestamp" \
               --header "RT_CONSUMER.ID: $consumer_id" \
               --header "RT_SEC.AUTH_SIGNATURE: $signature" \
               --header "RT_SVC.VERSION: 0.0.5" \
               --header "RT_QOS.CORRELATION_ID: $(uuidgen)" \
               --header "RT_SVC.NAME: OTEL-DEMO-SERVICE" \
               --header "RT_SVC.ENV: local" \
               --header "RT_CONSUMER.USER: job.runner@company.com" \
               --header "RT_CAMPAIGN.SOURCE: LOCAL_TEST" \
               --header "RT_SU_ID: 0" \
               --header "RT_SRT_ID: 0" \
               --header "Content-Type: application/json" \
               --data-raw '{"message": "Hello from Local Test"}' --insecure

    log "====== API Call Job Finished ======"
}

log "Starting API call job"
callApiEndpoint
log "Finished API call job. Exiting with exit code ${exitCode}..."
exit $exitCode
