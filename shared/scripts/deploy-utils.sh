#!/bin/bash
# Shared deployment utilities for COE AWS POCs

# Function to validate AWS profile
validate_aws_profile() {
    local profile="$1"
    if ! aws configure list-profiles 2>/dev/null | grep -q "^$profile$"; then
        echo "Error: Profile '$profile' does not exist in AWS credentials."
        echo "Available profiles:"
        aws configure list-profiles 2>/dev/null
        return 1
    fi
    return 0
}

# Function to validate AWS region format
validate_aws_region() {
    local region="$1"
    if [[ ! "$region" =~ ^[a-z]{2}-[a-z]+-[1-9][0-9]?$ ]]; then
        echo "Error: Invalid region format. Must be in format like us-east-2, eu-west-1, etc."
        return 1
    fi
    return 0
}

# Function to check if required tools are installed
check_prerequisites() {
    local tools=("$@")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo "Error: The following required tools are not installed:"
        printf '%s\n' "${missing_tools[@]}"
        return 1
    fi
    return 0
}

# Function to check Python version
check_python_version() {
    local required_version="$1"
    if ! command -v python3 &> /dev/null; then
        echo "Python3 is not installed. Please install Python3 to proceed."
        return 1
    fi
    
    local python_version=$(python3 --version 2>&1 | awk '{print $2}')
    if [[ "$python_version" != "$required_version"* ]]; then
        echo "Python version $required_version is required. Current version: $python_version"
        echo "Please install Python $required_version and try again."
        return 1
    fi
    return 0
}

# Function to create and manage EC2 key pairs
manage_ec2_keypair() {
    local profile="$1"
    local region="$2"
    local key_name="$3"
    local output_dir="$4"
    
    # Delete existing key pair if it exists
    aws ec2 delete-key-pair --region "$region" --profile "$profile" --key-name "$key_name" 2>/dev/null
    rm -f "$output_dir/$key_name.pem"
    
    # Create new key pair
    echo "Creating EC2 key pair: $key_name..."
    aws ec2 create-key-pair \
        --region "$region" \
        --profile "$profile" \
        --key-name "$key_name" \
        --query 'KeyMaterial' \
        --output text > "$output_dir/$key_name.pem"
    
    if [ $? -eq 0 ]; then
        chmod 400 "$output_dir/$key_name.pem"
        echo "EC2 key pair created successfully."
        return 0
    else
        echo "Failed to create EC2 key pair."
        return 1
    fi
}

# Function to wait for CloudFormation stack operation
wait_for_stack() {
    local profile="$1"
    local region="$2"
    local stack_name="$3"
    local operation="$4"  # create-complete, update-complete, delete-complete
    
    echo "Waiting for stack $stack_name to $operation..."
    aws cloudformation wait "stack-$operation" \
        --region "$region" \
        --profile "$profile" \
        --stack-name "$stack_name"
    
    if [ $? -eq 0 ]; then
        echo "Stack $stack_name $operation successfully."
        return 0
    else
        echo "Stack $stack_name failed to $operation."
        return 1
    fi
}

# Function to empty S3 bucket
empty_s3_bucket() {
    local profile="$1"
    local region="$2"
    local bucket_name="$3"
    
    echo "Emptying S3 bucket: $bucket_name..."
    aws s3 rm "s3://$bucket_name" --recursive --region "$region" --profile "$profile" 2>/dev/null
    echo "S3 bucket emptied."
}

# Function to display usage information
display_usage() {
    local script_name="$1"
    echo "Usage: $script_name [profile] [region]"
    echo "If no arguments are provided, defaults will be used:"
    echo "  Profile: default"
    echo "  Region: us-east-2"
    echo "Options:"
    echo "  --help    Display this help message"
} 