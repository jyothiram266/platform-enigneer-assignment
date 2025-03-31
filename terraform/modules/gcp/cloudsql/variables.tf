# ./modules/gcp/cloudsql/variables.tf

variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "instance_name" {
  description = "The name of the CloudSQL instance"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
}

variable "private_network" {
  description = "The self-link of the VPC network to connect to"
  type        = string
}

variable "tier" {
  description = "The machine type to use for the CloudSQL instance"
  type        = string
}

variable "database_version" {
  description = "The database version to use for the CloudSQL instance"
  type        = string
  default     = "POSTGRES_14"
}

variable "vpc_id" {
  description = "The self-link of the VPC network to connect to"
  type        = string
}