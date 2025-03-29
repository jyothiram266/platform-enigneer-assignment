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
  description = "Name for the RDS database"
  type        = string
}

variable "aws_database_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "aws_database_password" {
  description = "Password for the RDS database"
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

variable "gcp_subnet_cidrs" {
  description = "CIDR blocks for GCP subnets"
  type        = list(string)
  default     = ["10.1.0.0/24", "10.1.1.0/24"]
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

variable "gcp_database_name" {
  description = "Name for the Cloud SQL database"
  type        = string
}

variable "gcp_database_username" {
  description = "Username for the Cloud SQL database"
  type        = string
}

variable "gcp_database_password" {
  description = "Password for the Cloud SQL database"
  type        = string
  sensitive   = true
}