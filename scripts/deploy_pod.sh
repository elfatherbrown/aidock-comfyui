#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Default values
POD_NAME="comfyui-pod"
USE_SPOT="true"
TIMEOUT=300
CREATE_TEMPLATE=true
CLOUD_TYPE="SECURE"

# Parse command line arguments
function show_usage {
    echo "Usage: $0 <network_volume_id> [options]"
    echo "Required:"
    echo "  <network_volume_id>   Network volume ID to attach"
    echo "Options:"
    echo "  -t, --template <id>   Use existing template ID (skips template creation)"
    echo "  -n, --name <name>     Pod name (default: comfyui-pod)"
    echo "  -r, --reserved        Use reserved instance instead of spot/interruptible"
    echo "  -d, --datacenter <id> Override datacenter ID (otherwise uses volume's datacenter)"
    echo "  -c, --community       Use community cloud instead of secure cloud"
    echo "  --timeout <seconds>   Pod startup timeout in seconds (default: 300)"
    echo "  -h, --help            Show this help message"
    exit 1
}

# Check for minimum required args
if [ "$#" -lt 1 ]; then
    show_usage
fi

# Required parameters
VOLUME_ID=$1
shift 1

# Parse optional parameters
while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--template)
            TEMPLATE_ID="$2"
            CREATE_TEMPLATE=false
            shift 2
            ;;
        -n|--name)
            POD_NAME="$2"
            shift 2
            ;;
        -r|--reserved)
            USE_SPOT="false"
            shift
            ;;
        -d|--datacenter)
            DATACENTER="$2"
            shift 2
            ;;
        -c|--community)
            CLOUD_TYPE="COMMUNITY"
            shift
            ;;
        --timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            ;;
    esac
done

# If datacenter not specified, get it from the volume
if [ -z "$DATACENTER" ]; then
    echo -e "${YELLOW}Getting datacenter from volume $VOLUME_ID...${NC}"
    VOLUME_INFO=$(api_call "GET" "networkvolumes/$VOLUME_ID")
    DATACENTER=$(echo "$VOLUME_INFO" | jq -r '.dataCenterId // empty')
    
    if [ -z "$DATACENTER" ]; then
        echo -e "${RED}Failed to determine datacenter from volume${NC}"
        echo "$VOLUME_INFO"
        exit 1
    fi
    
    echo -e "${GREEN}Using datacenter: $DATACENTER from volume${NC}"
fi

# Handle template creation
if [ "$CREATE_TEMPLATE" = true ]; then
    # Check for template file
    if [ ! -f "runpod-template.json" ]; then
        echo -e "${RED}Error: runpod-template.json not found${NC}"
        exit 1
    fi

    # Create template from JSON
    echo -e "${YELLOW}Creating template from runpod-template.json...${NC}"
    TEMPLATE_DATA=$(cat runpod-template.json)
    RESULT=$(api_call "POST" "templates" "$TEMPLATE_DATA")
    TEMPLATE_ID=$(echo "$RESULT" | jq -r '.id // empty')

    if [ -z "$TEMPLATE_ID" ]; then
        echo -e "${RED}Failed to create template${NC}"
        echo "$RESULT"
        exit 1
    fi

    echo -e "${GREEN}Template created with ID: $TEMPLATE_ID${NC}"
else
    echo -e "${GREEN}Using existing template with ID: $TEMPLATE_ID${NC}"
fi

# Create the pod with the provided configuration
echo -e "${YELLOW}Creating pod with the following configuration:${NC}"
echo "Template ID: $TEMPLATE_ID"
echo "Data Center: $DATACENTER"
echo "Network Volume: $VOLUME_ID"
echo "Name: $POD_NAME"
echo "Using spot instance: $USE_SPOT"
echo "Cloud Type: $CLOUD_TYPE"
echo "Startup timeout: ${TIMEOUT}s"

POD_DATA=$(cat <<EOF
{
    "templateId": "$TEMPLATE_ID",
    "dataCenterIds": ["$DATACENTER"],
    "interruptible": $USE_SPOT,
    "name": "$POD_NAME",
    "networkVolumeId": "$VOLUME_ID",
    "cloudType": "$CLOUD_TYPE"
}
EOF
)

RESULT=$(api_call "POST" "pods" "$POD_DATA")
POD_ID=$(echo "$RESULT" | jq -r '.id')

if [ -z "$POD_ID" ] || [ "$POD_ID" = "null" ]; then
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

# Wait for pod to be running with timeout
echo -e "\n${YELLOW}Waiting for pod to be ready (timeout: ${TIMEOUT}s)...${NC}"
SECONDS=0
while [ $SECONDS -lt $TIMEOUT ]; do
    STATUS=$(check_pod_status "$POD_ID")
    if [ "$STATUS" = "RUNNING" ]; then
        echo -e "${GREEN}Pod is now running!${NC}"
        break
    elif [ "$STATUS" = "ERROR" ]; then
        echo -e "${RED}Pod failed to start${NC}"
        exit 1
    fi
    echo "Status: $STATUS (elapsed: ${SECONDS}s)"
    sleep 10
done

if [ $SECONDS -ge $TIMEOUT ]; then
    echo -e "${RED}Timed out waiting for pod to start${NC}"
    echo -e "${YELLOW}The pod may still start eventually. Check status with: runpodctl pods get $POD_ID${NC}"
    exit 1
fi

# Get final pod details
POD_DETAILS=$(api_call "GET" "pods/$POD_ID")
echo -e "\n${GREEN}Pod Details:${NC}"
echo "$POD_DETAILS" | jq '.'

# Extract and display connection information
POD_IP=$(echo "$POD_DETAILS" | jq -r '.publicIpAddress')
if [ -n "$POD_IP" ] && [ "$POD_IP" != "null" ]; then
    echo -e "\n${GREEN}Connection Information:${NC}"
    echo -e "ComfyUI URL: http://${POD_IP}:8188"
    echo -e "Jupyter URL: http://${POD_IP}:8888"
    echo -e "SSH Command: ssh -p 22 root@${POD_IP}"
fi

# Display commands for managing the pod
echo -e "\n${YELLOW}Pod Management:${NC}"
echo -e "Stop pod: runpodctl pods stop $POD_ID"
echo -e "Start pod: runpodctl pods start $POD_ID"
echo -e "Terminate pod: runpodctl remove pod $POD_ID" 
