# GCP VPC Variables
variable "vpc_name" {
  description = "Name of the GCP VPC"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for GCP subnet"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}