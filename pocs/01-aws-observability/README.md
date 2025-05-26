# AWS Observability POC

This POC demonstrates a comprehensive observability solution on AWS using CloudFormation templates. It provisions a dedicated VPC and deploys several key resources for monitoring and observability.

## Architecture Overview

![Application Composer diagram for the Cloudformation Template](docs/application-composer-poc-observability.png "Application Diagram")

## Components

- **AWS Managed Grafana Workspace**: Pre-configured with CloudWatch data source
- **Sample Lambda Function**: Deployed in private subnets with monitoring
- **Container Fleet (Auto Scaling Group)**: EC2 instances with CloudWatch Agent
- **DynamoDB Table**: Sample table for database monitoring
- **Networking**: Complete VPC setup with public/private subnets

## Resource Breakdown

### 1. VPC and Networking

- **VPC (10.0.0.0/24)**: Isolated network for all resources
- **Internet Gateway & VPC Gateway Attachment**: Public internet connectivity
- **Public Subnets (10.0.0.0/27 and 10.0.0.32/27)**: For EC2 instances
- **Private Subnets (10.0.0.64/27 and 10.0.0.96/27)**: For Lambda functions
- **Route Tables and Associations**: Proper routing configuration
- **NAT Gateway (with Elastic IP)**: Internet access for private resources

### 2. Observability Resources

- **AWS Managed Grafana Workspace**: Fully managed Grafana with CloudWatch integration
- **Grafana Service Role**: Necessary permissions for metric access

### 3. Application Resources

- **Sample Lambda Function**: Node.js function in private subnets
- **Container Fleet (Auto Scaling Group)**: Dynamic EC2 instances with CloudWatch Agent
- **Sample DynamoDB Table**: On-demand billing for monitoring demonstration

### 4. EC2 Grafana Instance

- **Grafana EC2 Instance**: Alternative Grafana deployment on EC2
- **Grafana EC2 Role**: CloudWatch read permissions

> **Note:** The EC2 Grafana instance is a temporary solution. AWS Managed Grafana is the preferred approach.

## Deployment Instructions

### Prerequisites
1. AWS CLI v2 installed
2. Python 3.12 installed
3. Valid AWS credentials configured

### Deploy
```bash
cd pocs/01-aws-observability
./scripts/deploy.sh <PROFILE_NAME> <REGION>
```

Where:
- `<PROFILE_NAME>` is your AWS CLI profile name
- `<REGION>` is the target AWS region

### Cleanup
```bash
./scripts/cleanup.sh <PROFILE_NAME> <REGION>
```

## Directory Structure

```
01-aws-observability/
├── README.md                    # This file
├── infrastructure/              # CloudFormation templates
│   ├── cf-template-s3.yaml     # S3 bucket for deployments
│   └── cf-template-infra.yaml  # Main infrastructure
├── lambda/                     # Lambda function code
│   ├── lambda_function.py      # Function implementation
│   └── requirements.txt        # Python dependencies
├── scripts/                    # Deployment scripts
│   ├── deploy.sh              # Deployment script
│   └── cleanup.sh             # Cleanup script
├── docs/                      # Documentation and diagrams
│   ├── poc-aws-obs-architecture-diagram.md
│   ├── aws_observability_poc_diagram.png
│   └── application-composer-poc-observability.png
└── tools/                     # POC-specific tools
    └── diagram-generator/     # Diagram generation utilities
        ├── script.py
        ├── requirements.txt
        └── README.md
```

## Key Features

- **Secure Architecture**: Private subnets for sensitive resources
- **Comprehensive Monitoring**: CloudWatch integration across all services
- **Scalable Design**: Auto Scaling Group for dynamic workloads
- **Infrastructure as Code**: Complete CloudFormation automation
- **Cost Optimized**: On-demand billing and right-sized instances 