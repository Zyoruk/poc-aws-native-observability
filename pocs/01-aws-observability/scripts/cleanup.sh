#!/bin/bash
# Request for profile and region as flags. Example: sh cleanup.sh LuisSimonEncora us-east-2

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

# Validate and set profile
if [[ $# -ge 1 && -n "$1" ]]; then
    # Check if the provided profile exists in AWS credentials
    if ! aws configure list-profiles 2>/dev/null | grep -q "^$1$"; then
        echo "Error: Profile '$1' does not exist in AWS credentials."
        echo "Available profiles:"
        aws configure list-profiles 2>/dev/null
        exit 1
    fi
    profile="$1"
else
    profile="$DEFAULT_PROFILE"
fi

# Validate and set region
if [[ $# -eq 2 && -n "$2" ]]; then
    # Basic region name validation (simple regex for AWS region format)
    if [[ ! "$2" =~ ^[a-z]{2}-[a-z]+-[1-9][0-9]?$ ]]; then
        echo "Error: Invalid region format. Must be in format like us-east-2, eu-west-1, etc."
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

# Print the profile and region
echo "Using AWS Profile: $profile"
echo "Using AWS Region: $region"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POC_DIR="$(dirname "$SCRIPT_DIR")"

# Get the S3 bucket name from the CloudFormation stack
bucket_name="coe-aws-obs-deployment-$region-$(aws sts get-caller-identity --query Account --output text --profile $profile)"

# Delete the main CloudFormation stack
echo "Deleting main CloudFormation stack: coe-aws-obs-poc-stack-infra..."
aws cloudformation delete-stack --region $region --profile $profile --stack-name coe-aws-obs-poc-stack-infra

# Wait for the main stack to be deleted
echo "Waiting for main CloudFormation stack to be deleted..."
aws cloudformation wait stack-delete-complete --region $region --profile $profile --stack-name coe-aws-obs-poc-stack-infra
echo "Main CloudFormation stack deleted."

# Empty the S3 bucket
echo "Emptying S3 bucket: $bucket_name..."
aws s3 rm s3://$bucket_name --recursive --region $region --profile $profile
echo "S3 bucket emptied."

# Delete the S3 bucket stack
echo "Deleting S3 bucket CloudFormation stack: coe-aws-obs-poc-stack-s3..."
aws cloudformation delete-stack --region $region --profile $profile --stack-name coe-aws-obs-poc-stack-s3

# Wait for the S3 bucket stack to be deleted
echo "Waiting for S3 bucket CloudFormation stack to be deleted..."
aws cloudformation wait stack-delete-complete --region $region --profile $profile --stack-name coe-aws-obs-poc-stack-s3
echo "S3 bucket CloudFormation stack deleted."

# Delete the EC2 key pair
echo "Deleting EC2 key pair: EC2KeyName..."
aws ec2 delete-key-pair --region $region --profile $profile --key-name EC2KeyName
echo "EC2 key pair deleted."

# Remove local key file if it exists
if [ -f "$POC_DIR/EC2KeyName.pem" ]; then
    rm -f "$POC_DIR/EC2KeyName.pem"
    echo "Local key file removed."
fi

echo "Cleanup completed successfully!"