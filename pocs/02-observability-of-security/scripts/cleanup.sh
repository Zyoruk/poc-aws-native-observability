#!/bin/bash
# [POC_NAME] Cleanup Script

# Function to display usage information
usage() {
    echo "Usage: $0 [profile] [region]"
    echo "If no arguments are provided, defaults will be used:"
    echo "  Profile: default"
    echo "  Region: us-east-2"
    echo "Options:"
    echo "  --help    Display this help message"
    exit 1
}

# Check if --help flag is used
if [[ "$1" == "--help" ]]; then
    usage
fi

# Set default values
DEFAULT_PROFILE="default"
DEFAULT_REGION="us-east-2"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POC_DIR="$(dirname "$SCRIPT_DIR")"

# Source shared utilities
source "$POC_DIR/../../shared/scripts/cleanup-utils.sh"

# Validate and set profile
if [[ $# -ge 1 && -n "$1" ]]; then
    if ! aws configure list-profiles 2>/dev/null | grep -q "^$1$"; then
        echo "Error: Profile '$1' does not exist in AWS credentials."
        exit 1
    fi
    profile="$1"
else
    profile="$DEFAULT_PROFILE"
fi

# Validate and set region
if [[ $# -eq 2 && -n "$2" ]]; then
    if [[ ! "$2" =~ ^[a-z]{2}-[a-z]+-[1-9][0-9]?$ ]]; then
        echo "Error: Invalid region format."
        exit 1
    fi
    region="$2"
else
    region="$DEFAULT_REGION"
fi

# Validate input argument count
if [[ $# -gt 2 ]]; then
    echo "Error: Too many arguments"
    usage
fi

echo "Using AWS Profile: $profile"
echo "Using AWS Region: $region"

# TODO: Add your cleanup logic here
echo "🚧 Cleanup logic not yet implemented"
echo "Please edit $0 to add your cleanup steps"

echo "Cleanup completed successfully!"
