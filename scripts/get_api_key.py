#!/usr/bin/env python3
import tomllib
import sys

def get_api_key(config_path):
    try:
        with open(config_path, "rb") as f:
            config = tomllib.load(f)
           
            return config.get("apikey")
    except Exception as e:
        print(f"Error reading config: {e}", file=sys.stderr)
        return None

if __name__ == "__main__":
    config_path = f"{sys.argv[1]}/.runpod/config.toml" if len(sys.argv) > 1 else f"{sys.path[0]}/.runpod/config.toml"
    api_key = get_api_key(config_path)
    if api_key:
        print(api_key)
    else:
        sys.exit(1) 