# Key is relative to $WORKSPACE/storage/

declare -A storage_map
storage_map["models"]="/opt/ComfyUI/models"
storage_map["outputs"]="/opt/ComfyUI/output"
storage_map["configurations"]="/opt/ComfyUI/extra_model_paths.yaml"
storage_map["workflows"]="/opt/ComfyUI/workflows"

# Add more mappings for other repository directories as needed