#!/bin/bash
# Request for profile and region as flags. Example: sh delete.sh LuisSimonEncora us-east-2
if [ $# -eq 0 ]; then
  echo "No arguments supplied"
  exit 1
fi
if [ $1 == "--help" ]; then
  echo "Usage: sh delete.sh <profile> <region>"
  exit 1
fi
if [ $# -ne 2 ]; then
  echo "Usage: sh delete.sh <profile> <region>"
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

# Get the S3 bucket name from the CloudFormation stack
bucket_name="coe-aws-obs-deployment-$region-$(aws sts get-caller-identity --query Account --output text --profile $profile)"

# Delete the main CloudFormation stack (template-ec2-grafana.yaml)
echo "Deleting main CloudFormation stack: coe-aws-obs-poc-stack..."
aws cloudformation delete-stack --region $region --profile $profile --stack-name coe-aws-obs-poc-stack

# Wait for the main stack to be deleted
echo "Waiting for main CloudFormation stack to be deleted..."
aws cloudformation wait stack-delete-complete --region $region --profile $profile --stack-name coe-aws-obs-poc-stack
echo "Main CloudFormation stack deleted."

# Empty the S3 bucket
echo "Emptying S3 bucket: $bucket_name..."
aws s3 rm s3://$bucket_name --recursive --region $region --profile $profile
echo "S3 bucket emptied."

# Delete the S3 bucket stack (template-s3-lambda.yaml)
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