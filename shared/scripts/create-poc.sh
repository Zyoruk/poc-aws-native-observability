#!/bin/bash
# Script to create a new POC from the template

# Function to display usage
usage() {
    echo "Usage: $0 <poc-number> <poc-name> [description]"
    echo ""
    echo "Examples:"
    echo "  $0 02 serverless-pipeline \"Serverless data processing pipeline\""
    echo "  $0 03 container-security"
    echo ""
    echo "Arguments:"
    echo "  poc-number    : Number for the POC (e.g., 02, 03, 04)"
    echo "  poc-name      : Descriptive name in kebab-case"
    echo "  description   : Optional description for the POC"
    exit 1
}

# Check arguments
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    usage
fi

POC_NUMBER="$1"
POC_NAME="$2"
POC_DESCRIPTION="${3:-Brief description of the POC}"

# Validate POC number format
if ! [[ "$POC_NUMBER" =~ ^[0-9]{2}$ ]]; then
    echo "Error: POC number must be a two-digit number (e.g., 02, 03, 04)"
    exit 1
fi

# Validate POC name format
if ! [[ "$POC_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo "Error: POC name must be in kebab-case (lowercase letters, numbers, and hyphens only)"
    exit 1
fi

# Create POC directory name
POC_DIR_NAME="${POC_NUMBER}-${POC_NAME}"
POC_FULL_PATH="pocs/${POC_DIR_NAME}"

# Get the script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Check if POC already exists
if [ -d "$REPO_ROOT/$POC_FULL_PATH" ]; then
    echo "Error: POC directory '$POC_FULL_PATH' already exists"
    exit 1
fi

echo "Creating new POC: $POC_DIR_NAME"
echo "Description: $POC_DESCRIPTION"
echo ""

# Copy template to new POC directory
echo "📁 Creating directory structure..."
cp -r "$REPO_ROOT/pocs/template" "$REPO_ROOT/$POC_FULL_PATH"

# Rename template README
mv "$REPO_ROOT/$POC_FULL_PATH/README.template.md" "$REPO_ROOT/$POC_FULL_PATH/README.md"

# Replace placeholders in README
echo "📝 Updating README.md..."
sed -i.bak "s/\[POC Name\]/${POC_NAME^}/g" "$REPO_ROOT/$POC_FULL_PATH/README.md"
sed -i.bak "s/\[Brief Description\]/$POC_DESCRIPTION/g" "$REPO_ROOT/$POC_FULL_PATH/README.md"
sed -i.bak "s/\[poc-directory-name\]/$POC_DIR_NAME/g" "$REPO_ROOT/$POC_FULL_PATH/README.md"
sed -i.bak "s/\[main purpose and goals of the POC\]/$POC_DESCRIPTION/g" "$REPO_ROOT/$POC_FULL_PATH/README.md"

# Remove backup file
rm "$REPO_ROOT/$POC_FULL_PATH/README.md.bak"

# Create basic deployment script
echo "🚀 Creating deployment script..."
cat > "$REPO_ROOT/$POC_FULL_PATH/scripts/deploy.sh" << 'EOF'
#!/bin/bash
# [POC_NAME] Deployment Script

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
source "$POC_DIR/../../shared/scripts/deploy-utils.sh"

# Validate and set profile
if [[ $# -ge 1 && -n "$1" ]]; then
    validate_aws_profile "$1" || exit 1
    profile="$1"
else
    profile="$DEFAULT_PROFILE"
fi

# Validate and set region
if [[ $# -eq 2 && -n "$2" ]]; then
    validate_aws_region "$2" || exit 1
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

# TODO: Add your deployment logic here
echo "🚧 Deployment logic not yet implemented"
echo "Please edit $0 to add your deployment steps"

echo "Deployment completed successfully!"
EOF

# Create basic cleanup script
echo "🧹 Creating cleanup script..."
cat > "$REPO_ROOT/$POC_FULL_PATH/scripts/cleanup.sh" << 'EOF'
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
EOF

# Replace POC_NAME placeholder in scripts
sed -i.bak "s/\[POC_NAME\]/${POC_NAME^}/g" "$REPO_ROOT/$POC_FULL_PATH/scripts/deploy.sh"
sed -i.bak "s/\[POC_NAME\]/${POC_NAME^}/g" "$REPO_ROOT/$POC_FULL_PATH/scripts/cleanup.sh"
rm "$REPO_ROOT/$POC_FULL_PATH/scripts/deploy.sh.bak"
rm "$REPO_ROOT/$POC_FULL_PATH/scripts/cleanup.sh.bak"

# Make scripts executable
chmod +x "$REPO_ROOT/$POC_FULL_PATH/scripts/"*.sh

# Create a basic CloudFormation template
echo "☁️ Creating basic CloudFormation template..."
cat > "$REPO_ROOT/$POC_FULL_PATH/infrastructure/cf-main.yaml" << EOF
AWSTemplateFormatVersion: '2010-09-09'
Description: '${POC_NAME^} POC - Main Infrastructure'

Parameters:
  Environment:
    Type: String
    Default: Development
    Description: Environment name
    
  ProjectName:
    Type: String
    Default: ${POC_DIR_NAME}
    Description: Project name for resource naming

Resources:
  # TODO: Add your AWS resources here
  
  # Example S3 bucket
  ExampleBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '\${ProjectName}-\${Environment}-\${AWS::AccountId}-\${AWS::Region}'
      Tags:
        - Key: POC
          Value: ${POC_DIR_NAME}
        - Key: Environment
          Value: !Ref Environment

Outputs:
  # TODO: Add your outputs here
  
  ExampleBucketName:
    Description: Name of the example S3 bucket
    Value: !Ref ExampleBucket
    Export:
      Name: !Sub '\${AWS::StackName}-ExampleBucket'
EOF

echo ""
echo "✅ POC '$POC_DIR_NAME' created successfully!"
echo ""
echo "📁 Location: $POC_FULL_PATH"
echo ""
echo "Next steps:"
echo "1. cd $POC_FULL_PATH"
echo "2. Edit README.md to add your specific documentation"
echo "3. Add your CloudFormation templates to infrastructure/"
echo "4. Add your source code to src/"
echo "5. Update scripts/deploy.sh with your deployment logic"
echo "6. Update scripts/cleanup.sh with your cleanup logic"
echo "7. Test your POC deployment"
echo "8. Update the main repository README.md to include your POC"
echo ""
echo "📖 See docs/poc-guidelines.md for detailed guidelines" 