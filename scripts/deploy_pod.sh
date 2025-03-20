#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Check if all required parameters are provided
if [ "$#" -lt 4 ]; then
    echo "Usage: $0 <template_id> <gpu_type> <datacenter_id> <network_volume_id> [pod_name]"
    echo "Example: $0 97r8bbcsuq \"NVIDIA RTX A4000\" EUR-IS-1 q9uuyjwk46 my-pod"
    exit 1
fi

TEMPLATE_ID=$1
DESIRED_GPU=$2
DATACENTER=$3
VOLUME_ID=$4
POD_NAME=${5:-"comfyui-pod"}

# Create the pod with the provided configuration
echo -e "${YELLOW}Creating pod with the following configuration:${NC}"
echo "Template ID: $TEMPLATE_ID"
echo "GPU Type: $DESIRED_GPU"
echo "Data Center: $DATACENTER"
echo "Network Volume: $VOLUME_ID"
echo "Name: $POD_NAME"

POD_DATA=$(cat <<EOF
{
    "templateId": "$TEMPLATE_ID",
    "gpuTypeId": "$DESIRED_GPU",
    "dataCenterId": ["$DATACENTER"],
    "spotInstance": true,
    "name": "$POD_NAME",
    "networkVolumeId": "$VOLUME_ID"
}
EOF
)

RESULT=$(api_call "POST" "pods" "$POD_DATA")
POD_ID=$(echo "$RESULT" | jq -r '.id')

if [ -z "$POD_ID" ]; then
    echo -e "${RED}Failed to create pod${NC}"
    echo "$RESULT"
    exit 1
fi

echo -e "\n${GREEN}Pod created successfully!${NC}"
echo "Pod ID: $POD_ID"

# Function to check pod status
check_pod_status() {
    local pod_id=$1
    local status=$(api_call "GET" "pods/$pod_id" | jq -r '.desiredStatus')
    echo "$status"
}

# Wait for pod to be running
echo -e "\n${YELLOW}Waiting for pod to be ready...${NC}"
while true; do
    STATUS=$(check_pod_status "$POD_ID")
    if [ "$STATUS" = "RUNNING" ]; then
        echo -e "${GREEN}Pod is now running!${NC}"
        break
    elif [ "$STATUS" = "ERROR" ]; then
        echo -e "${RED}Pod failed to start${NC}"
        exit 1
    fi
    echo "Status: $STATUS"
    sleep 10
done

# Get final pod details
POD_DETAILS=$(api_call "GET" "pods/$POD_ID")
echo -e "\n${GREEN}Pod Details:${NC}"
echo "$POD_DETAILS" | jq '.' 