#!/bin/bash
# Request for profile and region as flags. Example: sh deploy.sh LuisSimonEncora us-east-2

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

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
  echo "Python3 is not installed. Please install Python3 to proceed."
  exit 1
fi

# Check Python version
python_version=$(python --version 2>&1 | awk '{print $2}')
if [[ "$python_version" != "3.12"* ]]; then
  echo "Python version 3.12 is required for the Lambda function. Current version: $python_version"
  echo "Please install Python 3.12 and try again."
  exit 1
fi

# Check if pip is installed
if ! command -v pip &> /dev/null; then
  echo "pip is not installed. Please install pip to proceed."
  exit 1
fi

# Create an EC2 key pair named "EC2KeyName" and save the private key to a file.
# If it already exists, delete it first.
aws ec2 delete-key-pair --region "$region" --profile "$profile" --key-name EC2KeyName
rm -f "$POC_DIR/EC2KeyName.pem"

# Create the key pair and save the private key to a file.
aws ec2 create-key-pair --region "$region" --profile "$profile" --key-name EC2KeyName --query 'KeyMaterial' --output text > "$POC_DIR/EC2KeyName.pem"

# Empty the S3 bucket
bucket_name="coe-aws-obs-deployment-$region-$(aws sts get-caller-identity --query Account --output text --profile "$profile")"
echo "Emptying S3 bucket: $bucket_name..."
aws s3 rm "s3://$bucket_name" --recursive --region "$region" --profile "$profile"
echo "S3 bucket emptied."

# Deploy the first CloudFormation template to create the S3 bucket
echo "Deploying S3 bucket template..."
aws cloudformation deploy \
  --region "$region" \
  --profile "$profile" \
  --template-file "$POC_DIR/infrastructure/cf-template-s3.yaml" \
  --stack-name coe-aws-obs-poc-stack-s3 \
  --capabilities CAPABILITY_NAMED_IAM

# Create the Lambda deployment package
echo "Creating Lambda deployment package..."
mkdir -p "$POC_DIR/lambda_package"
cp "$POC_DIR/lambda/lambda_function.py" "$POC_DIR/lambda_package/"
cp "$POC_DIR/lambda/requirements.txt" "$POC_DIR/lambda_package/"
pip3 install -r "$POC_DIR/lambda_package/requirements.txt" -t "$POC_DIR/lambda_package/"
pushd "$POC_DIR/lambda_package"
zip -r "../lambda_function.zip" .
popd

# Upload the Lambda deployment package to the S3 bucket
bucket_name="coe-aws-obs-deployment-$region-$(aws sts get-caller-identity --query Account --output text --profile "$profile")"
echo "Uploading Lambda deployment package to S3..."
aws s3 cp "$POC_DIR/lambda_function.zip" "s3://$bucket_name/lambda/lambda_function.zip" --region "$region" --profile "$profile"

# Deploy the second CloudFormation template to create the rest of the resources
echo "Deploying main resources template..."
aws cloudformation deploy \
  --region "$region" \
  --profile "$profile" \
  --template-file "$POC_DIR/infrastructure/cf-template-infra.yaml" \
  --stack-name coe-aws-obs-poc-stack-infra \
  --parameter-overrides KeyName=EC2KeyName InstanceType=t3.small \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags POC=Observability

# Clean artifacts
rm -rf "$POC_DIR/lambda_function.zip"
rm -rf "$POC_DIR/lambda_package"

echo "Deployment completed successfully!"
echo "Check the AWS Console for the deployed resources."