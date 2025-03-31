# AWS RDS Variables
variable "identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where RDS will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS"
  type        = list(string)
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "database_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}

variable "master_username" {
  description = "Master username for PostgreSQL"
  type        = string
}

variable "master_password" {
  description = "Master password for PostgreSQL"
  type        = string
  sensitive   = true
}