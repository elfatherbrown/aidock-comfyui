#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Update template
echo -e "${YELLOW}Updating template...${NC}"
TEMPLATE_ID="d7ibe7tc2n"

# Create GraphQL mutation
GRAPHQL_QUERY='{
    "query": "mutation { saveTemplate(input: { id: \"d7ibe7tc2n\", containerDiskInGb: 12, dockerArgs: \"\", env: [ { key: \"AUTO_UPDATE\", value: \"true\" }, { key: \"CIVITAI_TOKEN\", value: \"{{ secrets.CIVITAI_API_KEY }}\" }, { key: \"COMFYUI_PORT_HOST\", value: \"8188\" }, { key: \"HF_TOKEN\", value: \"{{ secrets.HF_TOKEN }}\" }, { key: \"JUPYTER_PORT_HOST\", value: \"8888\" }, { key: \"SSH_PORT_HOST\", value: \"22\" }, { key: \"WEB_ENABLE_AUTH\", value: \"false\" }, { key: \"WORKSPACE\", value: \"/workspace\" } ], imageName: \"ghcr.io/elfatherbrown/aidock-comfyui:master\", name: \"ComfyUI elfatherbrown template\", ports: \"8188/http,8888/http,22/tcp\", readme: \"\", volumeInGb: 0 }) { id containerDiskInGb dockerArgs env { key value } imageName name ports readme volumeInGb } }"
}'

# Call GraphQL API
RESPONSE=$(curl -s -X POST \
    -H "content-type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    --data "$GRAPHQL_QUERY" \
    "https://api.runpod.io/graphql")

if [ -z "$RESPONSE" ]; then
    echo -e "${RED}Failed to update template${NC}"
    exit 1
fi

echo -e "${GREEN}Template updated successfully${NC}"
echo "$RESPONSE" | jq '.' 
