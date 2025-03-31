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

## 📁 **Directory and File Descriptions**

| Directory | Description | README File |
|-----------|-------------|-------------|
| `cost-optimisation/` | Strategies and documentation for cost optimization. | [README.md](cost-optimisation/README.md) |
| `kubernetes/` | Contains Kubernetes manifests and configurations. | [README.md](kubernetes/README.md) |
| `monitoring/` | Monitoring configurations for Grafana and Prometheus. | [README.md](monitoring/README.md) |
| `Prompts/` | Contains prompt templates or automation-related guidelines. | [README.md](Prompts/README.md) |
| `serverless/` | Contains serverless functions and related configurations. | [README.md](serverless/README.md) |
| `terraform/` | Infrastructure as Code (IaC) configurations using Terraform. | [README.md](terraform/README.md) |



This document provides an overview of the directory structure and links to relevant README files for detailed documentation. 🚀


---
