# ./modules/gcp/cloudsql/outputs.tf

output "project_id" {
  description = "The project ID where the CloudSQL instance is deployed"
  value       = var.project_id
}

output "instance_name" {
  description = "The name of the CloudSQL instance"
  value       = google_sql_database_instance.main.name
}

output "region" {
  description = "The region where the CloudSQL instance is deployed"
  value       = var.region
}

output "private_network" {
  description = "The VPC network connected to the CloudSQL instance"
  value       = var.private_network
}

output "tier" {
  description = "The machine tier of the CloudSQL instance"
  value       = var.tier
}

output "database_version" {
  description = "The database version of the CloudSQL instance"
  value       = var.database_version
}

output "connection_name" {
  description = "The connection name of the CloudSQL instance"
  value       = google_sql_database_instance.main.connection_name
}

output "private_ip_address" {
  description = "The private IP address assigned to the instance"
  value       = google_sql_database_instance.main.private_ip_address
}

output "self_link" {
  description = "The URI of the created resource"
  value       = google_sql_database_instance.main.self_link
}