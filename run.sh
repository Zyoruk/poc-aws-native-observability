#!/bin/bash
# Request for profile and region as flags. Example: sh run.sh LuisSimonEncora us-east-2

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

# Validate input arguments
if [ $# -eq 0 ]; then
  echo "No arguments supplied"
  exit 1
fi
if [ $1 == "--help" ]; then
  echo "Usage: sh run.sh <profile> <region>"
  exit 1
fi
if [ $# -ne 2 ]; then
  echo "Usage: sh run.sh <profile> <region>"
  exit 1
fi
if [ -z "$1" ]; then
  echo "Profile is empty"
  exit 1
fi
if [ -z "$2" ]; then
  echo "Region is empty"
  exit 1
fi

profile=$1
region=$2

# Print the profile and region
echo "Profile: $profile"
echo "Region: $region"

# Create an EC2 key pair named "EC2KeyName" and save the private key to a file.
# If it already exists, delete it first.
aws ec2 delete-key-pair --region $region --profile $profile --key-name EC2KeyName

rm EC2KeyName.pem

# Create the key pair and save the private key to a file.
aws ec2 create-key-pair --region $region --profile $profile --key-name EC2KeyName --query 'KeyMaterial' --output text > EC2KeyName.pem

# Empty the S3 bucket
bucket_name="coe-aws-obs-deployment-$region-$(aws sts get-caller-identity --query Account --output text --profile $profile)"
echo "Emptying S3 bucket: $bucket_name..."
aws s3 rm s3://$bucket_name --recursive --region $region --profile $profile
echo "S3 bucket emptied."

# Delete the S3 bucket stack if it exists
if aws cloudformation describe-stacks --region $region --profile $profile --stack-name coe-aws-obs-poc-stack-s3 &> /dev/null; then
  echo "Deleting S3 bucket CloudFormation stack: coe-aws-obs-poc-stack-s3..."
  aws cloudformation delete-stack --region $region --profile $profile --stack-name coe-aws-obs-poc-stack-s3

  # Wait for the S3 bucket stack to be deleted
  echo "Waiting for S3 bucket CloudFormation stack to be deleted..."
  aws cloudformation wait stack-delete-complete --region $region --profile $profile --stack-name coe-aws-obs-poc-stack-s3
  echo "S3 bucket CloudFormation stack deleted."
fi

# Deploy the first CloudFormation template to create the S3 bucket
echo "Deploying S3 bucket template..."
aws cloudformation deploy \
  --region $region \
  --profile $profile \
  --template-file cf-template-s3.yaml \
  --stack-name coe-aws-obs-poc-stack-s3 \
  --capabilities CAPABILITY_NAMED_IAM

# Create the Lambda deployment package
echo "Creating Lambda deployment package..."
mkdir -p lambda_package
cp lambda/lambda_function.py lambda_package/
cp lambda/requirements.txt lambda_package/
pip3 install -r lambda_package/requirements.txt -t lambda_package/
cd lambda_package
zip -r ../lambda_function.zip .
# 7z a -tzip -r ../lambda_function.zip .
cd ..

# Upload the Lambda deployment package to the S3 bucket
bucket_name="coe-aws-obs-deployment-$region-$(aws sts get-caller-identity --query Account --output text --profile $profile)"
echo "Uploading Lambda deployment package to S3..."
aws s3 cp lambda_function.zip s3://$bucket_name/lambda/lambda_function.zip --region $region --profile $profile

# Deploy the second CloudFormation template to create the rest of the resources
echo "Deploying main resources template..."
aws cloudformation deploy \
  --region $region \
  --profile $profile \
  --template-file cf-template-infra.yaml \
  --stack-name coe-aws-obs-poc-stack-infra \
  --parameter-overrides KeyName=EC2KeyName InstanceType=t3.small \
  --capabilities CAPABILITY_NAMED_IAM \
  --tags POC=Observability

# Clean artifacts
rm -rf lambda_function.zip
rm -rf lambda_package