#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get API key from RunPod config
RUNPOD_CONFIG="$HOME/.runpod/config.toml"
if [ ! -f "$RUNPOD_CONFIG" ]; then
    echo "Error: RunPod config file not found at $RUNPOD_CONFIG"
    echo "Please make sure you have runpodctl configured"
    exit 1
fi

API_KEY=$(python3 "$(dirname "$0")/get_api_key.py" "$HOME")
if [ -z "$API_KEY" ]; then
    echo "Error: API key not found in RunPod config"
    echo "Please configure runpodctl with: runpodctl config"
    exit 1
fi

# Function to make API calls
api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    
    if [ -z "$data" ]; then
        curl -s -X "$method" \
            -H "content-type: application/json" \
            -H "Authorization: Bearer $API_KEY" \
            "https://rest.runpod.io/v1/$endpoint"
    else
        curl -s -X "$method" \
            -H "content-type: application/json" \
            -H "Authorization: Bearer $API_KEY" \
            -d "$data" \
            "https://rest.runpod.io/v1/$endpoint"
    fi
} 