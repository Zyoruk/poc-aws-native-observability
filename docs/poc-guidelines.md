# POC Development Guidelines

This document outlines the standards and best practices for creating new POCs in this repository.

## POC Structure Requirements

### Directory Layout

Every POC must follow this structure:

```
pocs/[poc-name]/
├── README.md                    # POC documentation
├── infrastructure/              # Infrastructure as Code
│   ├── main-template.yaml      # Primary CloudFormation template
│   └── [additional-templates]  # Supporting templates
├── src/                        # Source code
│   ├── lambda/                 # Lambda functions
│   ├── scripts/                # Application scripts
│   └── [other-code]           # Additional source code
├── scripts/                    # Deployment automation
│   ├── deploy.sh              # Deployment script
│   └── cleanup.sh             # Cleanup script
└── docs/                      # Documentation and diagrams
    ├── architecture.md        # Architecture documentation
    └── diagrams/              # Architecture diagrams
```

### Naming Conventions

1. **POC Directory Names**
   - Format: `[number]-[descriptive-name]`
   - Examples: `02-serverless-pipeline`, `03-container-security`
   - Use kebab-case (lowercase with hyphens)
   - Keep names concise but descriptive

2. **File Names**
   - Use kebab-case for all files
   - CloudFormation templates: `cf-[purpose].yaml`
   - Scripts: descriptive names ending in `.sh`

3. **Resource Names**
   - Include POC identifier in resource names
   - Use consistent prefixes across the POC
   - Example: `poc-serverless-pipeline-lambda-function`

## Documentation Requirements

### README.md Structure

Every POC README must include:

```markdown
# [POC Name] - [Brief Description]

## Architecture Overview
[Architecture diagram and description]

## Components
[List of main components]

## Prerequisites
[Specific requirements for this POC]

## Deployment Instructions
[Step-by-step deployment guide]

## Directory Structure
[POC-specific structure]

## Key Features
[Highlighted features and capabilities]

## Testing
[How to test the POC]

## Troubleshooting
[Common issues and solutions]

## Cleanup
[How to remove all resources]
```

### Architecture Documentation

1. **Include Diagrams**
   - Create visual architecture diagrams
   - Use AWS Architecture Icons
   - Store in `docs/diagrams/`

2. **Document Design Decisions**
   - Explain why specific services were chosen
   - Document trade-offs and alternatives
   - Include cost considerations

## Infrastructure as Code Standards

### CloudFormation Templates

1. **Template Structure**
   ```yaml
   AWSTemplateFormatVersion: '2010-09-09'
   Description: '[POC Name] - [Template Purpose]'
   
   Parameters:
     # Required parameters
   
   Mappings:
     # Any mappings
   
   Resources:
     # All resources
   
   Outputs:
     # Important outputs
   ```

2. **Best Practices**
   - Use parameters for configurable values
   - Include meaningful descriptions
   - Add appropriate tags to all resources
   - Use outputs for important resource references

3. **Resource Tagging**
   ```yaml
   Tags:
     - Key: POC
       Value: [poc-name]
     - Key: Environment
       Value: Development
     - Key: Owner
       Value: [team-name]
   ```

### Security Requirements

1. **Network Security**
   - Use private subnets for sensitive resources
   - Implement proper security groups
   - Follow least-privilege principles

2. **IAM Policies**
   - Create specific roles for each service
   - Use managed policies when appropriate
   - Document required permissions

3. **Secrets Management**
   - Use AWS Secrets Manager or Parameter Store
   - Never hardcode credentials
   - Rotate secrets regularly

## Deployment Scripts Standards

### Script Requirements

1. **deploy.sh Structure**
   ```bash
   #!/bin/bash
   # [POC Name] Deployment Script
   
   # Source shared utilities
   source ../../shared/scripts/deploy-utils.sh
   
   # Validation and setup
   # Deployment logic
   # Success confirmation
   ```

2. **cleanup.sh Structure**
   ```bash
   #!/bin/bash
   # [POC Name] Cleanup Script
   
   # Source shared utilities
   source ../../shared/scripts/cleanup-utils.sh
   
   # Cleanup logic
   # Verification
   ```

3. **Error Handling**
   - Check for prerequisites
   - Validate inputs
   - Provide meaningful error messages
   - Exit with appropriate codes

### Shared Utilities Usage

Always use shared utilities when available:

```bash
# Validate AWS profile
validate_aws_profile "$profile"

# Manage EC2 key pairs
manage_ec2_keypair "$profile" "$region" "$key_name" "$output_dir"

# Wait for stack operations
wait_for_stack "$profile" "$region" "$stack_name" "create-complete"
```

## Testing Requirements

### Pre-Deployment Testing

1. **Template Validation**
   ```bash
   aws cloudformation validate-template --template-body file://template.yaml
   ```

2. **Script Testing**
   - Test with different AWS profiles
   - Test in different regions
   - Verify error handling

### Post-Deployment Testing

1. **Functional Testing**
   - Verify all resources are created
   - Test application functionality
   - Check monitoring and logging

2. **Cleanup Testing**
   - Ensure cleanup script removes all resources
   - Verify no orphaned resources remain
   - Test cleanup in failure scenarios

## Cost Considerations

### Resource Sizing

1. **Use Appropriate Instance Types**
   - Start with smaller instances (t3.micro, t3.small)
   - Document scaling considerations
   - Consider spot instances for non-critical workloads

2. **Storage Optimization**
   - Use appropriate storage classes
   - Implement lifecycle policies
   - Consider data retention requirements

### Cost Monitoring

1. **Resource Tagging**
   - Tag all resources for cost tracking
   - Use consistent tagging strategy
   - Include cost center information

2. **Cleanup Automation**
   - Provide clear cleanup instructions
   - Automate resource deletion
   - Set up cost alerts if needed

## Quality Checklist

Before submitting a new POC, ensure:

- [ ] Directory structure follows standards
- [ ] README.md is complete and accurate
- [ ] Architecture diagram is included
- [ ] CloudFormation templates are valid
- [ ] Deployment script works correctly
- [ ] Cleanup script removes all resources
- [ ] All resources are properly tagged
- [ ] Security best practices are followed
- [ ] Documentation is clear and complete
- [ ] Testing has been performed
- [ ] Main repository README is updated

## Review Process

1. **Self-Review**
   - Test deployment and cleanup
   - Review documentation for clarity
   - Verify all requirements are met

2. **Peer Review**
   - Have another team member review
   - Test deployment in different environment
   - Provide feedback on documentation

3. **Final Approval**
   - Address all review comments
   - Update documentation as needed
   - Merge to main branch

## Maintenance

### Regular Updates

1. **Keep Templates Current**
   - Update to latest CloudFormation features
   - Review and update AMI IDs
   - Update software versions

2. **Documentation Maintenance**
   - Keep README files current
   - Update architecture diagrams
   - Review and update troubleshooting guides

3. **Security Updates**
   - Review IAM policies regularly
   - Update security group rules
   - Apply security patches

### Deprecation Process

When a POC becomes outdated:

1. Mark as deprecated in README
2. Update main repository index
3. Provide migration path if applicable
4. Archive after appropriate notice period 