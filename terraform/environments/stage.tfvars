# Environment
environment = "prod"

# AWS Configuration
aws_region = "us-west-2"
aws_vpc_cidr = "10.0.0.0/16"
aws_availability_zones = ["us-west-2a", "us-west-2b"]
aws_private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
aws_public_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
aws_eks_node_count = 2
aws_eks_instance_type = "t3.medium"
aws_rds_instance_class = "db.t3.medium"
aws_database_name = "myapp"
aws_database_username = "admin"
aws_database_password = "your-secure-password"

# GCP Configuration
gcp_project_id = "your-project-id"
gcp_region = "us-central1"
gcp_subnet_cidrs = ["10.1.0.0/24", "10.1.1.0/24"]
gcp_gke_node_count = 2
gcp_gke_machine_type = "n1-standard-2"
gcp_cloudsql_tier = "db-f1-micro"
gcp_database_name = "myapp"
gcp_database_username = "admin"
gcp_database_password = "your-secure-password"