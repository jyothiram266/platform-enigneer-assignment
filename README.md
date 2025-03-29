# Multi-Cloud Infrastructure Project

This project implements a production-grade infrastructure across AWS and GCP with automated CI/CD pipelines and comprehensive monitoring.

The High Level Architecture Diagram
![architecture](./screenshots/image.png)


## 🏗 Infrastructure Components

### AWS Infrastructure

#### VPC Configuration
- VPC with `/16` CIDR block
- 2 public and 2 private subnets across different availability zones
- Internet Gateway and NAT Gateway for outbound access
- Secure routing tables and network ACLs

#### EKS (Elastic Kubernetes Service)
- Managed Kubernetes cluster with 2 worker nodes
- Auto-scaling enabled for worker nodes
- IAM roles with least privilege access
- Secure pod networking

#### RDS (PostgreSQL)
- PostgreSQL instance in private subnet
- Encryption at rest using AWS KMS
- Automated backups enabled
- Restricted security group access

#### S3 Storage
- S3 bucket for Terraform state
- Versioning enabled
- Server-side encryption
- DynamoDB table for state locking

### GCP Infrastructure

#### VPC Configuration
- VPC with dedicated subnets
- Private Google Access enabled
- Secure firewall rules

#### GKE (Google Kubernetes Engine)
- Managed Kubernetes cluster
- Node auto-scaling
- Private cluster configuration
- Workload Identity enabled

#### Cloud SQL (PostgreSQL)
- PostgreSQL instance in private subnet
- Automated backups
- Encryption enabled
- Private service access

## 🚀 CI/CD Pipeline

The CI/CD pipeline is implemented using GitHub Actions and includes:

### Workflow Triggers
- Push to `main` branch
- Pull requests

### Jobs

1. **Lint & Security Checks**
   - Terraform formatting check
   - Checkov security scanning

2. **AWS Deployment**
   - AWS credentials configuration
   - Terraform plan and apply
   - Infrastructure validation

3. **GCP Deployment**
   - GCP authentication
   - Parallel infrastructure deployment
   - Resource validation

4. **Post-Deployment Tests**
   - Health checks for AWS and GCP endpoints
   - Automated validation
   - Failure notifications

## 📊 Monitoring & Observability

### Metrics Collection (Prometheus)
- 15-second scrape interval
- Service discovery for:
  - Kubernetes nodes
  - AWS EC2 instances
  - GCP Compute instances

### Logging Setup

#### AWS CloudWatch
- Log group: `eks-logs`
- 7-day retention period
- Structured logging

#### GCP Cloud Logging
- Log sink: `gke-logs`
- Cloud Storage bucket integration
- Automated log routing

### Grafana Dashboards
- Multi-cloud infrastructure metrics
- Real-time monitoring panels:
  - CPU Usage
  - Memory Usage
  - Network Traffic
- Auto-refresh every 10 seconds

### Alerting (Prometheus Alertmanager)
- Critical alerts for instance downtime
- Performance threshold alerts
- Cloud-specific alert routing

## 🛠 Setup Instructions

### Prerequisites
- AWS CLI configured
- GCloud SDK installed
- Terraform >= 1.0.0
- kubectl installed
- Helm 3.x

### Infrastructure Deployment

1. Initialize Terraform:
```bash
terraform init
```

2. Create terraform.tfvars file:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit variables as needed
```

3. Deploy infrastructure:
```bash
terraform apply -var-file=terraform.tfvars
```

### Monitoring Setup

1. Deploy Prometheus stack:
```bash
helm install prometheus prometheus-community/kube-prometheus-stack -f kubernetes/prometheus/values.yaml
```

2. Access Grafana:
```bash
kubectl port-forward svc/prometheus-grafana 3000:80
```

3. Import dashboards from `monitoring/grafana/grafana-dash.json`

## 🔐 Security Features

- IAM roles with least privilege
- Network isolation
- Encryption at rest
- Private subnets for sensitive resources
- Security group restrictions
- Regular security scanning

## 📝 Maintenance

### Backup Strategy
- Automated RDS backups
- Cloud SQL automated backups
- S3 versioning
- State file backups

### Scaling Guidelines
- Node auto-scaling configuration
- Database scaling procedures
- Storage scaling recommendations

# Multi-Cloud Infrastructure CI/CD

This document describes the GitHub Actions workflow that handles continuous integration and deployment of infrastructure as code (IaC) across AWS and GCP environments.

## Workflow Overview

The workflow automates the deployment of infrastructure changes to both AWS and GCP clouds using Terraform. It includes linting, security scanning, and post-deployment health checks to ensure a reliable infrastructure deployment pipeline.

![architecture](./screenshots/Screenshot%20from%202025-03-29%2018-51-03.png)

## Workflow Triggers

The workflow is triggered on:
- Push events to the `main` branch (deploys to production)
- Push events to the `stage` branch (deploys to staging)
- Only when changes are made to files within the `terraform/` directory

## Environment Variables

The workflow uses the following environment variables:

| Variable | Description | Value |
|----------|-------------|-------|
| `AWS_REGION` | AWS deployment region | us-east-1 |
| `GCP_PROJECT_ID` | GCP project identifier | Retrieved from repository secrets |
| `TF_VAR_environment` | Deployment environment | Determined based on branch (`main` → prod, `stage` → stage) |

## Workflow Steps

### 1. Lint and Security Checks

This job performs preparatory validation of the Terraform code:

- Checks Terraform formatting using `terraform fmt`
- Runs Checkov security scan to identify potential security issues
- Blocks further deployment if any checks fail

### 2. AWS Infrastructure Deployment

This job handles deployment to AWS and runs in parallel with GCP deployment:

- Configures AWS credentials from repository secrets
- Initializes Terraform
- Creates a deployment plan using environment-specific variables
- Applies the Terraform configuration to AWS
- Sends a notification to Slack if deployment fails

### 3. GCP Infrastructure Deployment

This job handles deployment to GCP and runs in parallel with AWS deployment:

- Authenticates with Google Cloud using service account credentials
- Initializes Terraform
- Creates a deployment plan using environment-specific variables 
- Applies the Terraform configuration to GCP
- Sends a notification to Slack if deployment fails

### 4. Post-Deployment Tests

After both cloud deployments complete successfully, this job:

- Performs health checks on the deployed AWS API endpoints
- Performs health checks on the deployed GCP API endpoints
- Sends a success notification to Slack if all tests pass

## Required Secrets

The following secrets must be configured in the GitHub repository:

| Secret Name | Description |
|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | AWS IAM access key ID |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret access key |
| `GCP_PROJECT_ID` | Google Cloud project identifier |
| `GCP_CREDENTIALS` | Google Cloud service account JSON key |
| `SLACK_WEBHOOK_URL` | Webhook URL for Slack notifications |

## Directory Structure

The workflow expects the following directory structure:

```
.
├── terraform/           # Terraform configuration files
│   └── ...
├── environments/        # Environment-specific configurations
│   ├── prod.tfvars      # Production Terraform variables
│   └── stage.tfvars     # Staging Terraform variables
└── .github/
    └── workflows/
        └── multi-cloud-cicd.yml  # This workflow file
```

## Terraform Initialization

The workflow initializes Terraform directly without using backend configuration files:

```yaml
- name: Terraform Init
  run: terraform init
```

## Notifications

The workflow sends the following notifications to Slack:
- 🚨 AWS Deployment Failed! Check the logs.
- 🚨 GCP Deployment Failed! Check the logs.
- ✅ Multi-Cloud Deployment Successful!

## Success Criteria

A successful deployment must meet all the following criteria:
1. Pass all lint and security checks
2. Successfully apply Terraform configurations to both AWS and GCP
3. Pass all post-deployment health checks

## Troubleshooting

If deployment fails:
1. Check the GitHub Actions logs for detailed error messages
2. Verify that all required secrets are properly configured
3. Ensure the Terraform configuration is valid and formatted correctly
4. Verify that the environment variable files (*.tfvars) exist and are formatted correctly