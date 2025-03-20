#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Check if datacenter ID is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <datacenter_id>"
    echo "Example: $0 EUR-IS-1"
    exit 1
fi

DATACENTER=$1

# Get available pods in the datacenter
echo -e "${YELLOW}Checking available GPUs in $DATACENTER...${NC}"
PODS=$(api_call "GET" "pods?dataCenterId=[$DATACENTER]")
if [ -z "$PODS" ]; then
    echo -e "${RED}Failed to fetch pod information${NC}"
    exit 1
fi

# Format and display GPU information
echo -e "${GREEN}Available GPUs in $DATACENTER:${NC}"
echo "$PODS" | jq -r '.[] | "Pod ID: \(.id)\nGPU Type: \(.machine.gpuTypeId)\nMemory: \(.memoryInGb)GB\nvCPUs: \(.vcpuCount)\nCost per hour: $\(.costPerHr)\n"' 