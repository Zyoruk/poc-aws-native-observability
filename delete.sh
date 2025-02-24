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

aws cloudformation delete-stack --region $region --profile $profile --stack-name coe-aws-obs-poc-stack
aws ec2 delete-key-pair --region $region  --profile $profile --key-name EC2KeyName