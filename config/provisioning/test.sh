#!/bin/bash

# This file will be sourced in init.sh
# Test configuration with only public nodes

DEFAULT_WORKFLOW=""

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager.git"
)

# Initialize empty arrays
CHECKPOINT_MODELS=()
VAE_MODELS=()
CLIP_MODELS=()
ESRGAN_MODELS=()

# Ensure workspace directories exist
mkdir -p "${WORKSPACE}/storage/stable_diffusion/models/ckpt"
mkdir -p "${WORKSPACE}/storage/stable_diffusion/models/vae"
mkdir -p "${WORKSPACE}/storage/stable_diffusion/models/esrgan"
mkdir -p "${WORKSPACE}/storage/models"
mkdir -p "${WORKSPACE}/storage/outputs"
mkdir -p "${WORKSPACE}/storage/workflows"

# If config doesn't exist, create a basic one
if [[ ! -f "${WORKSPACE}/storage/configurations" ]]; then
    cat > "${WORKSPACE}/storage/configurations" <<EOL
extra_model_paths:
  - /opt/ComfyUI/models
EOL
fi

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###
source /opt/ai-dock/bin/provisioning.sh 