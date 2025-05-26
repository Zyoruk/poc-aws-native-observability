# COE AWS Observability - Multi-POC Repository

This repository contains multiple Proof-of-Concepts (POCs) demonstrating various AWS solutions and best practices. Each POC is self-contained with its own infrastructure, documentation, and deployment scripts.

## Repository Structure

```
coe-aws-obs/
├── README.md                          # This file - repository overview
├── .gitignore                         # Git ignore patterns
├── shared/                            # Shared utilities and resources
│   └── scripts/                       # Common deployment utilities
│       ├── deploy-utils.sh           # Deployment helper functions
│       ├── cleanup-utils.sh          # Cleanup helper functions
│       └── create-poc.sh             # Script to create new POCs
├── pocs/                              # Individual POCs
│   ├── 01-aws-observability/          # AWS Observability POC
│   │   ├── README.md                  # POC-specific documentation
│   │   ├── infrastructure/            # CloudFormation templates
│   │   │   ├── cf-template-s3.yaml   # S3 bucket template
│   │   │   └── cf-template-infra.yaml # Main infrastructure template
│   │   ├── lambda/                    # Lambda function code
│   │   │   ├── lambda_function.py    # Function implementation
│   │   │   └── requirements.txt      # Python dependencies
│   │   ├── scripts/                   # Deployment scripts
│   │   │   ├── deploy.sh             # Deployment script
│   │   │   └── cleanup.sh            # Cleanup script
│   │   ├── docs/                      # Documentation and diagrams
│   │   │   ├── poc-aws-obs-architecture-diagram.md
│   │   │   ├── aws_observability_poc_diagram.png
│   │   │   └── application-composer-poc-observability.png
│   │   └── tools/                     # POC-specific tools
│   │       └── diagram-generator/     # Diagram generation utilities
│   │           ├── script.py
│   │           ├── requirements.txt
│   │           └── README.md
│   └── template/                      # Template for new POCs
│       ├── README.template.md         # Template README
│       ├── infrastructure/            # Template infrastructure directory
│       ├── src/                       # Template source code directory
│       ├── scripts/                   # Template scripts directory
│       └── docs/                      # Template documentation directory
└── docs/                              # Repository-level documentation
    ├── getting-started.md             # Comprehensive setup guide
    └── poc-guidelines.md              # Standards for creating POCs
```

## Available POCs

### 1. AWS Observability POC (`pocs/01-aws-observability/`)

A comprehensive observability solution demonstrating:
- AWS Managed Grafana with CloudWatch integration
- Lambda function monitoring in private subnets
- EC2 Auto Scaling Group with CloudWatch Agent
- DynamoDB monitoring
- Complete VPC setup with security best practices

**Quick Start:**
```bash
cd pocs/01-aws-observability
./scripts/deploy.sh <AWS_PROFILE> <AWS_REGION>
```

[📖 Full Documentation](pocs/01-aws-observability/README.md)

---

## Getting Started

### Prerequisites

1. **AWS CLI v2** - [Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. **Valid AWS Credentials** - Configure with `aws configure`
3. **Python 3.12** - Required for Lambda functions
4. **Bash Shell** - For running deployment scripts

### Quick Setup

1. **Clone the repository:**
   ```bash
   git clone git@github.com:Zyoruk/poc-aws-native-observability.git
   cd poc-aws-native-observability
   ```

2. **Choose a POC:**
   ```bash
   cd pocs/[poc-name]
   ```

3. **Deploy:**
   ```bash
   ./scripts/deploy.sh <AWS_PROFILE> <AWS_REGION>
   ```

4. **Cleanup when done:**
   ```bash
   ./scripts/cleanup.sh <AWS_PROFILE> <AWS_REGION>
   ```

## Creating New POCs

### Using the Automated Script

The easiest way to create a new POC is using the provided script:

```bash
./shared/scripts/create-poc.sh 02 serverless-pipeline "Serverless data processing pipeline"
```

This will:
- Create the directory structure from the template
- Generate basic deployment and cleanup scripts
- Create a starter CloudFormation template
- Update the README with your POC details

### Manual Creation

1. **Copy the template:**
   ```bash
   cp -r pocs/template pocs/[new-poc-name]
   ```

2. **Update the README:**
   - Edit `pocs/[new-poc-name]/README.md`
   - Replace placeholders with actual content

3. **Add your infrastructure:**
   - CloudFormation templates in `infrastructure/`
   - Source code in `src/`
   - Deployment scripts in `scripts/`

4. **Update this main README** to include your new POC

### POC Naming Convention

- Use descriptive, kebab-case names: `02-serverless-data-pipeline`
- Include a number prefix for ordering: `03-container-security`
- Keep names concise but clear

## Shared Resources

### Deployment Utilities (`shared/scripts/`)

Common functions for AWS operations:
- **`deploy-utils.sh`**: Validation, key management, stack operations
- **`cleanup-utils.sh`**: Resource cleanup and verification
- **`create-poc.sh`**: Automated POC creation from template

### Usage in POC Scripts

```bash
# Source shared utilities
source ../../shared/scripts/deploy-utils.sh

# Use shared functions
validate_aws_profile "$profile"
manage_ec2_keypair "$profile" "$region" "MyKeyName" "$POC_DIR"
wait_for_stack "$profile" "$region" "$stack_name" "create-complete"
```

## Best Practices

### Infrastructure as Code
- Use CloudFormation for all AWS resources
- Parameterize templates for reusability
- Include proper resource tagging

### Security
- Deploy sensitive resources in private subnets
- Use least-privilege IAM policies
- Rotate access keys regularly

### Cost Management
- Use appropriate instance sizes
- Implement auto-scaling where beneficial
- Clean up resources after testing

### Documentation
- Include architecture diagrams
- Document deployment steps clearly
- Provide troubleshooting guides

## Contributing

1. **Create a new POC** using the template structure or automated script
2. **Follow naming conventions** and best practices
3. **Test thoroughly** before committing
4. **Update documentation** including this main README
5. **Submit a pull request** with clear description

## Support

For questions or issues:
1. Check the individual POC documentation
2. Review troubleshooting sections in [docs/getting-started.md](docs/getting-started.md)
3. Follow the guidelines in [docs/poc-guidelines.md](docs/poc-guidelines.md)
4. Create an issue in the repository

## Documentation

- **[Getting Started Guide](docs/getting-started.md)** - Complete setup and usage instructions
- **[POC Development Guidelines](docs/poc-guidelines.md)** - Standards and best practices for creating POCs


## POC Index

| POC | Description | Status | Technologies |
|-----|-------------|--------|--------------|
| [01-aws-observability](pocs/01-aws-observability/) | Comprehensive AWS monitoring solution | ✅ Active | Grafana, CloudWatch, Lambda, EC2, DynamoDB |
| [template](pocs/template/) | Template for new POCs | 📋 Template | - |

---

*Repository restructured for multi-POC organization - Ready for scaling with additional proof-of-concepts*