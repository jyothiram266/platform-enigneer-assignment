# GCP GKE Variables
variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where GKE will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for GKE"
  type        = string
}

variable "node_count" {
  description = "Number of GKE worker nodes"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "n1-standard-2"
}