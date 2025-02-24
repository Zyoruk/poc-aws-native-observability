# Summary
Holds the configuration for COE AWS Observability native deployment.

## Prerequisites
1. have AWS CLI@v2 installed

## Steps
1. make sure to login to AWS in the CLI
2. `$ cd coe-aws-observability`
3. `$ sh run.sh <PROFILE_NAME> <REGION>` where:
    - `<PROFILE_NAME>` is the AWS CLI profile name
    - `<REGION>` is the AWS region to deploy the resources
### To delete the resources
3. `$ sh delete.sh`