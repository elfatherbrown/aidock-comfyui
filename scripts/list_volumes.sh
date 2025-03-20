#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Get available network volumes
echo -e "${YELLOW}Fetching available network volumes...${NC}"
VOLUMES=$(api_call "GET" "networkvolumes")
if [ -z "$VOLUMES" ]; then
    echo -e "${RED}Failed to fetch network volumes${NC}"
    exit 1
fi

# Format and display volumes
echo -e "${GREEN}Available Network Volumes:${NC}"
echo "$VOLUMES" | jq -r '.[] | "ID: \(.id)\nName: \(.name)\nData Center: \(.dataCenterId)\nSize: \(.size)GB\n"' 