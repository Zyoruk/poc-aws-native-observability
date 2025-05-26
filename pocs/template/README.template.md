# [POC Name] - [Brief Description]

This POC demonstrates [main purpose and goals of the POC].

## Architecture Overview

[Add architecture diagram here]

## Components

- **Component 1**: Description
- **Component 2**: Description
- **Component 3**: Description

## Prerequisites

1. [List prerequisites here]
2. AWS CLI v2 installed
3. Valid AWS credentials configured

## Deployment Instructions

### Deploy
```bash
cd pocs/[poc-directory-name]
./scripts/deploy.sh <PROFILE_NAME> <REGION>
```

### Cleanup
```bash
./scripts/cleanup.sh <PROFILE_NAME> <REGION>
```

## Directory Structure

```
[poc-directory-name]/
├── README.md                    # This file
├── infrastructure/              # Infrastructure as Code templates
├── src/                        # Source code
├── scripts/                    # Deployment and utility scripts
│   ├── deploy.sh              # Deployment script
│   └── cleanup.sh             # Cleanup script
└── docs/                      # Documentation and diagrams
```

## Key Features

- **Feature 1**: Description
- **Feature 2**: Description
- **Feature 3**: Description

## Testing

[Describe how to test the POC]

## Troubleshooting

[Common issues and solutions]

## Next Steps

[Potential improvements or extensions] 