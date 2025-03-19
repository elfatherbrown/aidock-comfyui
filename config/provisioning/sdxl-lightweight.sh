#!/bin/bash

# This file will be sourced in init.sh
# Lightweight SDXL configuration

DEFAULT_WORKFLOW="https://raw.githubusercontent.com/elfatherbrown/aidock-comfyui/sdxl-lightweight/config/workflows/sdxl-lightweight-example.json"

NODES=(
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/stabilityai/sd-webui-stability-nodes"
)

function check_model() {
    local url=$1
    local dir=$2
    local filename=$(basename "$url")
    if [[ -f "${dir}/${filename}" ]]; then
        return 0
    fi
    return 1
}

# Initialize empty arrays
CHECKPOINT_MODELS=()
VAE_MODELS=()
CLIP_MODELS=()
ESRGAN_MODELS=()

# Define model URLs
SDXL_TURBO_URL="https://huggingface.co/stabilityai/sdxl-turbo/resolve/main/sd_xl_turbo_1.0_fp16.safetensors"
SDXL_VAE_URL="https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors"
ESRGAN_URL="https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth"

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

# Check and populate arrays
if ! check_model "$SDXL_TURBO_URL" "${WORKSPACE}/storage/stable_diffusion/models/ckpt"; then
    CHECKPOINT_MODELS+=("$SDXL_TURBO_URL")
fi

if ! check_model "$SDXL_VAE_URL" "${WORKSPACE}/storage/stable_diffusion/models/vae"; then
    VAE_MODELS+=("$SDXL_VAE_URL")
fi

if ! check_model "$ESRGAN_URL" "${WORKSPACE}/storage/stable_diffusion/models/esrgan"; then
    ESRGAN_MODELS+=("$ESRGAN_URL")
fi

### DO NOT EDIT BELOW HERE UNLESS YOU KNOW WHAT YOU ARE DOING ###
source /opt/ai-dock/bin/provisioning.sh 