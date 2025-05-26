# Getting Started with COE AWS Observability POCs

This guide will help you get up and running with the POCs in this repository.

## Prerequisites

### Required Tools

1. **AWS CLI v2**
   ```bash
   # Install on macOS
   brew install awscli
   
   # Install on Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   
   # Verify installation
   aws --version
   ```

2. **Python 3.12**
   ```bash
   # Install on macOS
   brew install python@3.12
   
   # Install on Linux (Ubuntu/Debian)
   sudo apt update
   sudo apt install python3.12 python3.12-pip
   
   # Verify installation
   python3.12 --version
   ```

3. **Git**
   ```bash
   # Install on macOS
   brew install git
   
   # Install on Linux
   sudo apt install git
   ```

### AWS Configuration

1. **Configure AWS Credentials**
   ```bash
   aws configure
   ```
   
   You'll need:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region (e.g., `us-east-2`)
   - Default output format (recommend `json`)

2. **Verify Configuration**
   ```bash
   aws sts get-caller-identity
   ```

3. **Multiple Profiles (Optional)**
   ```bash
   aws configure --profile myprofile
   ```

## Repository Setup

1. **Clone the Repository**
   ```bash
   git clone git@github.com:Zyoruk/poc-aws-native-observability.git
   cd poc-aws-native-observability
   ```

2. **Explore the Structure**
   ```bash
   tree -L 3
   ```

3. **Make Scripts Executable**
   ```bash
   find . -name "*.sh" -exec chmod +x {} \;
   ```

## Running Your First POC

### AWS Observability POC

1. **Navigate to the POC**
   ```bash
   cd pocs/01-aws-observability
   ```

2. **Review the Documentation**
   ```bash
   cat README.md
   ```

3. **Deploy the POC**
   ```bash
   ./scripts/deploy.sh default us-east-2
   ```
   
   Replace `default` with your AWS profile and `us-east-2` with your preferred region.

4. **Monitor the Deployment**
   - Check the AWS CloudFormation console
   - Watch for any error messages in the terminal

5. **Access the Resources**
   - Find the Grafana workspace URL in the AWS console
   - Check the Lambda function in the AWS console
   - Review CloudWatch metrics

6. **Clean Up**
   ```bash
   ./scripts/cleanup.sh default us-east-2
   ```

## Common Issues and Solutions

### Permission Errors

**Issue**: `AccessDenied` errors during deployment

**Solution**: Ensure your AWS user/role has sufficient permissions:
- CloudFormation full access
- EC2 full access
- Lambda full access
- IAM role creation permissions
- S3 full access

### Python Version Issues

**Issue**: Lambda deployment fails due to Python version

**Solution**: 
```bash
# Check Python version
python3 --version

# Install Python 3.12 if needed
# See prerequisites section above
```

### Region-Specific Issues

**Issue**: Some services not available in your region

**Solution**: Use a region that supports all required services:
- Recommended: `us-east-1`, `us-east-2`, `us-west-2`, `eu-west-1`

### Key Pair Issues

**Issue**: EC2 key pair already exists

**Solution**: The scripts automatically handle this, but you can manually delete:
```bash
aws ec2 delete-key-pair --key-name EC2KeyName --region us-east-2
```

## Best Practices

### Cost Management

1. **Always Clean Up**
   - Run cleanup scripts after testing
   - Monitor your AWS billing dashboard

2. **Use Appropriate Regions**
   - Choose regions close to you for better performance
   - Consider cost differences between regions

3. **Monitor Resource Usage**
   - Set up billing alerts
   - Use AWS Cost Explorer

### Security

1. **Rotate Access Keys**
   - Regularly rotate your AWS access keys
   - Use IAM roles when possible

2. **Least Privilege**
   - Only grant necessary permissions
   - Review IAM policies regularly

3. **Network Security**
   - POCs use private subnets for sensitive resources
   - Review security group rules

### Development Workflow

1. **Branch Strategy**
   ```bash
   git checkout -b feature/new-poc
   # Make changes
   git commit -m "Add new POC"
   git push origin feature/new-poc
   ```

2. **Testing**
   - Test deployments in a development AWS account
   - Verify cleanup procedures work

3. **Documentation**
   - Update README files
   - Include architecture diagrams
   - Document any prerequisites

## Next Steps

1. **Explore Other POCs**
   - Check the `pocs/` directory for additional examples
   - Review different architectural patterns

2. **Create Your Own POC**
   - Use the template in `pocs/template/`
   - Follow the naming conventions
   - Add to the main README

3. **Contribute**
   - Submit improvements via pull requests
   - Share your POCs with the team
   - Update documentation

## Getting Help

1. **Check Documentation**
   - Individual POC README files
   - This getting started guide
   - AWS documentation

2. **Common Resources**
   - [AWS CLI Documentation](https://docs.aws.amazon.com/cli/)
   - [CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
   - [AWS Best Practices](https://aws.amazon.com/architecture/well-architected/)

3. **Support Channels**
   - Create issues in this repository
   - Team chat channels
   - AWS support (if available) 