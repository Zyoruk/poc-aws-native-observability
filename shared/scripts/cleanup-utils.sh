#!/bin/bash
# Shared cleanup utilities for COE AWS POCs

# Function to delete CloudFormation stack
delete_cloudformation_stack() {
    local profile="$1"
    local region="$2"
    local stack_name="$3"
    local wait_for_completion="${4:-true}"
    
    echo "Deleting CloudFormation stack: $stack_name..."
    aws cloudformation delete-stack \
        --region "$region" \
        --profile "$profile" \
        --stack-name "$stack_name"
    
    if [ "$wait_for_completion" = "true" ]; then
        echo "Waiting for stack $stack_name to be deleted..."
        aws cloudformation wait stack-delete-complete \
            --region "$region" \
            --profile "$profile" \
            --stack-name "$stack_name"
        
        if [ $? -eq 0 ]; then
            echo "Stack $stack_name deleted successfully."
            return 0
        else
            echo "Failed to delete stack $stack_name."
            return 1
        fi
    fi
}

# Function to delete EC2 key pair
delete_ec2_keypair() {
    local profile="$1"
    local region="$2"
    local key_name="$3"
    local local_key_path="$4"
    
    echo "Deleting EC2 key pair: $key_name..."
    aws ec2 delete-key-pair \
        --region "$region" \
        --profile "$profile" \
        --key-name "$key_name"
    
    if [ $? -eq 0 ]; then
        echo "EC2 key pair deleted successfully."
    else
        echo "Failed to delete EC2 key pair (it may not exist)."
    fi
    
    # Remove local key file if it exists
    if [ -n "$local_key_path" ] && [ -f "$local_key_path" ]; then
        rm -f "$local_key_path"
        echo "Local key file removed: $local_key_path"
    fi
}

# Function to empty and optionally delete S3 bucket
cleanup_s3_bucket() {
    local profile="$1"
    local region="$2"
    local bucket_name="$3"
    local delete_bucket="${4:-false}"
    
    echo "Emptying S3 bucket: $bucket_name..."
    aws s3 rm "s3://$bucket_name" --recursive --region "$region" --profile "$profile" 2>/dev/null
    echo "S3 bucket emptied."
    
    if [ "$delete_bucket" = "true" ]; then
        echo "Deleting S3 bucket: $bucket_name..."
        aws s3 rb "s3://$bucket_name" --region "$region" --profile "$profile" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "S3 bucket deleted successfully."
        else
            echo "Failed to delete S3 bucket (it may not exist or may not be empty)."
        fi
    fi
}

# Function to clean up local artifacts
cleanup_local_artifacts() {
    local artifacts=("$@")
    
    for artifact in "${artifacts[@]}"; do
        if [ -e "$artifact" ]; then
            rm -rf "$artifact"
            echo "Removed local artifact: $artifact"
        fi
    done
}

# Function to list and optionally delete CloudFormation stacks by prefix
cleanup_stacks_by_prefix() {
    local profile="$1"
    local region="$2"
    local stack_prefix="$3"
    local confirm_delete="${4:-false}"
    
    echo "Finding stacks with prefix: $stack_prefix"
    local stacks=$(aws cloudformation list-stacks \
        --region "$region" \
        --profile "$profile" \
        --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE \
        --query "StackSummaries[?starts_with(StackName, '$stack_prefix')].StackName" \
        --output text)
    
    if [ -z "$stacks" ]; then
        echo "No stacks found with prefix: $stack_prefix"
        return 0
    fi
    
    echo "Found stacks:"
    echo "$stacks" | tr '\t' '\n'
    
    if [ "$confirm_delete" = "true" ]; then
        for stack in $stacks; do
            delete_cloudformation_stack "$profile" "$region" "$stack" true
        done
    else
        echo "Use confirm_delete=true to delete these stacks."
    fi
}

# Function to verify cleanup completion
verify_cleanup() {
    local profile="$1"
    local region="$2"
    local stack_names=("${@:3}")
    
    echo "Verifying cleanup completion..."
    local failed_cleanups=()
    
    for stack_name in "${stack_names[@]}"; do
        if aws cloudformation describe-stacks \
            --region "$region" \
            --profile "$profile" \
            --stack-name "$stack_name" &>/dev/null; then
            failed_cleanups+=("$stack_name")
        fi
    done
    
    if [ ${#failed_cleanups[@]} -eq 0 ]; then
        echo "✅ All resources cleaned up successfully."
        return 0
    else
        echo "❌ The following stacks still exist:"
        printf '%s\n' "${failed_cleanups[@]}"
        return 1
    fi
} 