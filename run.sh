#!/bin/bash
# Request for profile and region as flags. Example: sh run.sh LuisSimonEncora us-east-2
if [ $# -eq 0 ]; then
  echo "No arguments supplied"
  exit 1
fi
if [ $1 == "--help" ]; then
  echo "Usage: sh run.sh <profile> <region>"
  exit 1
fi
if [ $# -ne 3 ]; then
  echo "Usage: sh run.sh <profile> <region> <template>"
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
if [ -z "$3" ]; then
  echo "Template is empty"
  exit 1
fi
profile=$1
region=$2
template=$3

# Print the profile and region
echo "Profile: $profile"
echo "Region: $region"
echo "Template: $template"

# Create an EC2 key pair named "EC2KeyName" and save the private key to a file.
# If it already exists, delete it first.
aws ec2 delete-key-pair --region $region  --profile $profile --key-name EC2KeyName

rm EC2KeyName.pem

# Create the key pair and save the private key to a file.
aws ec2 create-key-pair  --region $region  --profile $profile --key-name EC2KeyName --query 'KeyMaterial'  --output text > EC2KeyName.pem

# Deploy the CloudFormation stack using the updated template file "observability-poc.yaml".
aws cloudformation deploy \
  --region $region \
  --profile $profile \
  --template-file $template \
  --stack-name coe-aws-obs-poc-stack \
  --parameter-overrides KeyName=EC2KeyName InstanceType=t3.micro \
  --capabilities CAPABILITY_NAMED_IAM