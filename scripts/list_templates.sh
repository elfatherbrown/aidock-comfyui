#!/bin/bash

# Source common functions
source "$(dirname "$0")/common.sh"

# Check if a template ID was provided for detailed view
TEMPLATE_ID=$1

if [ -z "$TEMPLATE_ID" ]; then
    # List all templates
    echo -e "${YELLOW}Available Templates:${NC}"
    TEMPLATES=$(api_call "GET" "templates")
    echo "$TEMPLATES" | jq -r '.[] | "ID: \(.id) | Name: \(.name) | Image: \(.imageName) | Container Disk: \(.containerDisk)GB"'
    
    echo -e "\n${GREEN}For template details, run:${NC}"
    echo "$0 <template_id>"
else
    # Show detailed information for specific template
    echo -e "${YELLOW}Template Details for ID: $TEMPLATE_ID${NC}"
    TEMPLATE=$(api_call "GET" "templates/$TEMPLATE_ID")
    echo "$TEMPLATE" | jq '.'
fi