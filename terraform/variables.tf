# Root Variables
variable "environment" {
  description = "Environment name (e.g., prod, staging, dev)"
  type        = string
}

# AWS Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_availability_zones" {
  description = "List of AWS availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "aws_private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "aws_eks_node_count" {
  description = "Number of EKS worker nodes"
  type        = number
  default     = 2
}

variable "aws_eks_instance_type" {
  description = "Instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "aws_rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "aws_database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}

variable "aws_database_username" {
  description = "Master username for PostgreSQL"
  type        = string
}

variable "aws_database_password" {
  description = "Master password for PostgreSQL"
  type        = string
  sensitive   = true
}

# GCP Variables
variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_vpc_cidr" {
  description = "CIDR block for GCP VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "gcp_gke_node_count" {
  description = "Number of GKE worker nodes"
  type        = number
  default     = 2
}

variable "gcp_gke_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "n1-standard-2"
}

variable "gcp_cloudsql_tier" {
  description = "Machine tier for Cloud SQL"
  type        = string
  default     = "db-f1-micro"
}