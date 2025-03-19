#!/bin/bash

# Test directory structure
test_dirs=(
    "/workspace/storage/models"
    "/workspace/storage/outputs"
    "/workspace/storage/workflows"
)

# Test model paths (after mapping)
test_paths=(
    "/opt/ComfyUI/models/checkpoints/sd_xl_turbo_1.0_fp16.safetensors"
    "/opt/ComfyUI/models/vae/sdxl_vae.safetensors"
    "/opt/ComfyUI/output"
    "/opt/ComfyUI/workflows"
)

# Test symlinks
test_symlinks=(
    "/opt/ComfyUI/models"
    "/opt/ComfyUI/output"
)

printf "Running tests...\n\n"

# Test 1: Directory Structure
printf "Testing directory structure...\n"
for dir in "${test_dirs[@]}"; do
    if [[ -d $dir ]]; then
        printf "✓ Directory exists: %s\n" "$dir"
    else
        printf "✗ Directory missing: %s\n" "$dir"
        exit 1
    fi
done

# Test 2: Model Downloads
printf "\nTesting model downloads...\n"
for path in "${test_paths[@]}"; do
    if [[ -e $path ]]; then
        printf "✓ File/Directory exists: %s\n" "$path"
    else
        printf "✗ File/Directory missing: %s\n" "$path"
        exit 1
    fi
done

# Test 3: Symlinks
printf "\nTesting symlinks...\n"
for link in "${test_symlinks[@]}"; do
    if [[ -L $link ]]; then
        printf "✓ Symlink exists: %s -> %s\n" "$link" "$(readlink -f "$link")"
    else
        printf "✗ Symlink missing: %s\n" "$link"
        exit 1
    fi
done

printf "\nAll tests passed!\n" 