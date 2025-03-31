# Multi-Cloud Infrastructure Deployment Script

This Bash script automates Terraform deployments across AWS and GCP with comprehensive features for secure, controlled infrastructure provisioning.

## Features

- **Multi-cloud support**: Handles AWS and GCP authentication and deployment
- **Security scanning**: Integrates with tfsec and checkov for security validation
- **Interactive workflow**: Includes confirmation steps for critical operations
- **Comprehensive logging**: Detailed colorized console logs and log files
- **Validation checks**: Ensures proper Terraform configuration and formatting

## Prerequisites

- Terraform CLI
- AWS CLI with configured credentials
- Google Cloud SDK (gcloud)
- Optional: tfsec and checkov for security scanning

## Configuration

Edit these variables at the top of the script:

```bash
AWS_PROFILE="default"         # AWS CLI profile to use
GCP_PROJECT_ID=""             # Your Google Cloud project ID
TERRAFORM_DIR="./terraform"   # Directory containing Terraform configurations
LOG_DIR="./deployment_logs"   # Directory for log files
```

## Usage

1. Ensure you have the required tools installed
2. Configure your AWS and GCP credentials
3. Run the script:

```bash
./deploy.sh
```

## Workflow

The script follows this sequence:

1. **Environment setup**: Creates log directories and checks required tools
2. **Cloud authentication**: Verifies and sets up AWS and GCP credentials
3. **Terraform initialization**: Initializes and validates Terraform configurations
4. **Security scanning**: Runs security tools to identify potential issues
5. **Deployment**: Plans and applies infrastructure changes with approval steps
6. **Output capture**: Saves deployment outputs for later reference

## Logs and Outputs

All actions are logged to:
- Terminal output with color coding
- Date-stamped log files in the `LOG_DIR` directory
- Terraform outputs as JSON in the logs directory

## Security Considerations

- Security scans are run before deployment
- Results are saved for review
- User confirmation is required before proceeding with deployment
- Terraforming formatting is verified

## Error Handling

The script uses strict error handling (`set -eo pipefail`) and will:
- Exit on first error
- Check and report command exit status
- Provide clear error messages

## Example Output

```
[INFO] 2025-03-31 10:15:30 - Starting multi-cloud infrastructure deployment
[INFO] 2025-03-31 10:15:30 - Deployment ID: deploy_20250331_101530
[INFO] 2025-03-31 10:15:30 - Setting up deployment environment
[INFO] 2025-03-31 10:15:30 - Checking required tools...
[SUCCESS] 2025-03-31 10:15:31 - Environment setup complete
[INFO] 2025-03-31 10:15:31 - Authenticating with AWS using profile: default
[SUCCESS] 2025-03-31 10:15:32 - AWS authentication successful
...
[SUCCESS] 2025-03-31 10:20:45 - Deployment completed successfully. Log saved to: ./deployment_logs/deploy_20250331_101530.log
```

## Customization

The script can be extended by:
- Adding more cloud providers
- Incorporating additional security scanning tools
- Customizing the deployment workflow for specific needs

## Troubleshooting

If you encounter issues:
1. Check the log file for detailed error messages
2. Verify your cloud credentials
3. Ensure your Terraform configurations are valid
4. Confirm required APIs are enabled in GCP