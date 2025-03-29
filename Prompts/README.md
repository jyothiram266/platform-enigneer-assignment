This is are the Refined prompts i have used for creating the infra:   

### **1️⃣ Terraform Code Generation**  
*"Generate Terraform code for a multi-cloud infrastructure deployment across AWS and GCP. Follow best practices for security, scalability, and automation. Ensure the code is modular using Terraform modules and includes appropriate outputs for key resources."*  

#### **AWS Resources:**  
- **VPC:** Create a `/16` CIDR block with 2 public and 2 private subnets, an Internet Gateway, and a NAT Gateway.  
- **EKS Cluster:** Deploy a managed Kubernetes cluster with 2 worker nodes, IAM role-based access control, and auto-scaling.  
- **RDS PostgreSQL:** Deploy a managed PostgreSQL instance in a private subnet with AWS KMS encryption.  
- **S3 Storage:** Set up an S3 bucket for Terraform remote state with versioning and encryption.  
- **IAM Roles & Policies:** Define least privilege IAM roles for EKS and Terraform CI/CD.  

#### **GCP Resources:**  
- **VPC:** Create a `/16` CIDR block with 2 public and 2 private subnets.  
- **GKE Cluster:** Deploy a managed Kubernetes cluster with 2 worker nodes, IAM-based authentication, and auto-scaling.  
- **Cloud SQL PostgreSQL:** Deploy a managed PostgreSQL instance in a private subnet with encryption and automated backups.  
- **Cloud Storage:** Set up a GCS bucket for Terraform remote state with versioning and encryption.  
- **IAM Policies:** Implement least privilege access control for Terraform deployments.  

---

### **2️⃣ Architecture Diagram Generation**  
*"Generate a high-level architecture diagram for a multi-cloud infrastructure deployment across AWS and GCP. The diagram should include labeled components such as VPCs, subnets, Kubernetes clusters, databases, storage solutions, IAM policies, and networking elements. Use color coding to distinguish AWS and GCP resources. Indicate network flows and dependencies with arrows. Security components such as VPC Peering, VPN, and firewall rules should also be visualized."*  

---

### **3️⃣ Security Policy Recommendations**  
*"Generate security best practices for a multi-cloud infrastructure deployment using AWS and GCP. Focus on IAM least privilege access, encryption standards, firewall rules, and network segmentation. Ensure secure communication between AWS and GCP using VPC Peering or VPN, and recommend monitoring solutions such as AWS CloudTrail, AWS CloudWatch, Google Cloud Monitoring, and Google Cloud Audit Logs."*  

---

### **4️⃣ CI/CD Pipeline (GitHub Actions) Generation**  
*"Generate a GitHub Actions workflow for a Terraform-based multi-cloud infrastructure deployment. The workflow should include the following stages:  
1️⃣ Code scanning (Terraform linting, tfsec, checkov)  
2️⃣ Security checks (IAM policy validation, misconfiguration detection)  
3️⃣ Multi-cloud deployment (AWS & GCP)  
4️⃣ Automated testing (infrastructure validation and health checks)."*  

---

### **5️⃣ Bash Script for Infrastructure Automation**  
*"Generate a Bash script to automate Terraform deployment for AWS and GCP. The script should:  
1️⃣ Initialize Terraform and validate configurations  
2️⃣ Authenticate with AWS and GCP  
3️⃣ Run security checks using tfsec and checkov  
4️⃣ Apply Terraform configurations and output results  
5️⃣ Log all deployment steps for debugging."*  

These prompts will help you generate Terraform code, architecture diagrams, security policies, CI/CD workflows, and automation scripts for your project. 🚀