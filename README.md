# Multi-Cloud Infrastructure Project

This project implements a production-grade infrastructure across AWS and GCP with automated CI/CD pipelines and comprehensive monitoring.


# Project Directory Structure

This repository contains configurations and scripts for Kubernetes, monitoring, serverless applications, and infrastructure management using Terraform. Below is an overview of the directory structure and the contents of each folder.

---

## 📂 **Directory Structure**

```bash
├── cost-optimisation/
│   └── README.md
├── kubernetes/
│   ├── cert-manager/
│   │   ├── certificate.yaml
│   │   ├── eks-clusterissuer.yaml
│   │   └── gke-clusterissuer.yaml
│   ├── depolyment-manifest/
│   │   ├── depolyment.yaml
│   │   ├── gateway.yaml
│   │   ├── service.yaml
│   │   └── virtualservice.yaml
│   └── README.md
├── monitoring/
│   ├── grafana/
│   │   └── grafana-dash.json
│   ├── prometheus/
│   │   └── alert-rules.yml
│   ├── Readme.md
│   └── values.yaml
├── Prompts/
│   └── README.md
├── screenshots/
│   ├── image.png
│   ├── Screenshot from 2025-03-29 18-51-03.png
│   ├── Screenshot from 2025-03-29 23-44-44.png
├── serverless/
│   ├── ec2-backup-lambda/
│   │   ├── app.py
│   │   └── template.yaml
│   └── README.md
└── terraform/
    ├── main.tf
    ├── modules/
    │   ├── aws/
    │   │   ├── eks/
    │   │   │   ├── main.tf
    │   │   │   └── variables.tf
    │   │   ├── rds/
    │   │   │   ├── main.tf
    │   │   │   └── variables.tf
    │   │   └── vpc/
    │   │       ├── main.tf
    │   │       ├── outputs.tf
    │   │       └── variables.tf
    │   ├── gcp/
    │   │   ├── cloudsql/
    │   │   │   ├── main.tf
    │   │   │   ├── output.tf
    │   │   │   └── variables.tf
    │   │   ├── gke/
    │   │   │   ├── main.tf
    │   │   │   └── variables.tf
    │   │   └── vpc/
    │   │       ├── main.tf
    │   │       ├── outputs.tf
    │   │       └── variables.tf
    ├── outputs.tf
    ├── package.json
    ├── package-lock.json
    ├── README.md
    ├── terraform.tfvars.example
    └── variables.tf
```

---

## 📁 **Directory and File Descriptions**

### 🏷️ **1. cost-optimisation/**
Contains strategies and documentation for cost optimization.
- **`README.md`** – Explanation of cost-optimization techniques and best practices.

### 🛠️ **2. kubernetes/**
Contains Kubernetes manifests and configurations.

#### **cert-manager/**
- **`certificate.yaml`** – Defines a Kubernetes certificate resource.
- **`eks-clusterissuer.yaml`** – Defines a ClusterIssuer for EKS.
- **`gke-clusterissuer.yaml`** – Defines a ClusterIssuer for GKE.

#### **depolyment-manifest/** *(Note: "depolyment" should be "deployment")*
- **`depolyment.yaml`** – Defines a Kubernetes Deployment.
- **`gateway.yaml`** – Istio Gateway configuration.
- **`service.yaml`** – Defines a Kubernetes Service.
- **`virtualservice.yaml`** – Defines an Istio VirtualService.

- **`README.md`** – Documentation for Kubernetes configurations.

### 📊 **3. monitoring/**
Contains monitoring configurations for Grafana and Prometheus.

#### **grafana/**
- **`grafana-dash.json`** – Grafana dashboard configuration.

#### **prometheus/**
- **`alert-rules.yml`** – Prometheus alert rules.

- **`Readme.md`** – Documentation for monitoring setup.
- **`values.yaml`** – Configuration values for monitoring tools (likely for Helm charts).

### 💡 **4. Prompts/**
Contains prompt templates or automation-related guidelines.
- **`README.md`** – Explanation of prompt usage.

### 📸 **5. screenshots/**
Stores image files related to the project, such as UI screenshots and diagrams.

### ⚡ **6. serverless/**
Contains serverless functions and related configurations.

#### **ec2-backup-lambda/**
- **`app.py`** – AWS Lambda function (likely for EC2 backups).
- **`template.yaml`** – AWS SAM or CloudFormation template.

- **`README.md`** – Documentation for the serverless functions.

### 🌍 **7. terraform/**
Contains Infrastructure as Code (IaC) configurations using Terraform.

#### **modules/**
- **aws/** – Terraform modules for AWS infrastructure.
  - **`eks/`** – Manages Amazon EKS (Elastic Kubernetes Service).
  - **`rds/`** – Manages AWS RDS (Relational Database Service).
  - **`vpc/`** – Manages AWS VPC (Virtual Private Cloud).

- **gcp/** – Terraform modules for GCP infrastructure.
  - **`cloudsql/`** – Manages Google Cloud SQL.
  - **`gke/`** – Manages Google Kubernetes Engine.
  - **`vpc/`** – Manages Google Cloud VPC.

#### Other Terraform files:
- **`main.tf`** – Main Terraform configuration.
- **`variables.tf`** – Input variables for Terraform.
- **`outputs.tf`** – Defines Terraform outputs.
- **`terraform.tfvars.example`** – Example Terraform variables file.
- **`package.json` & `package-lock.json`** – Might be related to a Terraform plugin or supporting Node.js scripts.
- **`README.md`** – Documentation for Terraform usage.

---


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