output "aws_vpc_id" {
  description = "ID of the AWS VPC"
  value       = module.aws_vpc.vpc_id
}

output "aws_eks_endpoint" {
  description = "Endpoint for AWS EKS cluster"
  value       = module.aws_eks.cluster_endpoint
}

output "aws_rds_endpoint" {
  description = "Endpoint for AWS RDS instance"
  value       = module.aws_rds.endpoint
}

output "gcp_vpc_id" {
  description = "ID of the GCP VPC"
  value       = module.gcp_vpc.vpc_id
}

output "gcp_gke_endpoint" {
  description = "Endpoint for GKE cluster"
  value       = module.gcp_gke.cluster_endpoint
}

output "gcp_cloudsql_connection_name" {
  description = "Connection name for Cloud SQL instance"
  value       = module.gcp_cloudsql.connection_name
}