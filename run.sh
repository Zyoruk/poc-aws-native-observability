# Request for profile and region as flags. Example: sh run.sh LuisSimonEncora us-east-2
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
aws ec2 delete-key-pair --region $region  --profile $profile --key-name EC2KeyName
# if the file exists locally
if [ -f EC2KeyName.pem ]; then
  rm EC2KeyName.pem
fi

# Create the key pair and save the private key to a file.
aws ec2 create-key-pair  --region $region  --profile $profile --key-name EC2KeyName --query 'KeyMaterial'  --output text > EC2KeyName.pem

# Set the permissions of the private key file to read-only.
chmod 400 EC2KeyName.pem

# Deploy the CloudFormation stack using the updated template file "observability-poc.yaml".
aws cloudformation deploy \
  --region $region \
  --profile $profile \
  --template-file template.yaml \
  --stack-name coe-aws-obs-poc-stack \
  --parameter-overrides KeyName=EC2KeyName InstanceType=t3.micro \
  --capabilities CAPABILITY_NAMED_IAM