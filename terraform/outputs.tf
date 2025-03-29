output "aws_vpc_id" {
  description = "AWS VPC ID"
  value       = module.aws_vpc.vpc_id
}

output "aws_eks_endpoint" {
  description = "AWS EKS cluster endpoint"
  value       = module.aws_eks.cluster_endpoint
}

output "aws_rds_endpoint" {
  description = "AWS RDS endpoint"
  value       = module.aws_rds.endpoint
}

output "gcp_vpc_id" {
  description = "GCP VPC ID"
  value       = module.gcp_vpc.vpc_id
}

output "gcp_gke_endpoint" {
  description = "GCP GKE cluster endpoint"
  value       = module.gcp_gke.cluster_endpoint
}

output "gcp_cloudsql_connection_name" {
  description = "GCP Cloud SQL connection name"
  value       = module.gcp_cloudsql.connection_name
}