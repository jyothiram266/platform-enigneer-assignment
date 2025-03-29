terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-multicloud"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# AWS Infrastructure
module "aws_vpc" {
  source = "./modules/aws/vpc"
  
  vpc_cidr             = var.aws_vpc_cidr
  environment          = var.environment
  availability_zones   = var.aws_availability_zones
  private_subnet_cidrs = var.aws_private_subnet_cidrs
  public_subnet_cidrs  = var.aws_public_subnet_cidrs
}

module "aws_eks" {
  source = "./modules/aws/eks"
  
  cluster_name       = "${var.environment}-eks-cluster"
  vpc_id            = module.aws_vpc.vpc_id
  private_subnet_ids = module.aws_vpc.private_subnet_ids
  node_count        = var.aws_eks_node_count
  instance_type     = var.aws_eks_instance_type
}

module "aws_rds" {
  source = "./modules/aws/rds"
  
  identifier        = "${var.environment}-postgres"
  vpc_id           = module.aws_vpc.vpc_id
  subnet_ids       = module.aws_vpc.private_subnet_ids
  instance_class   = var.aws_rds_instance_class
  database_name    = var.aws_database_name
  master_username  = var.aws_database_username
  master_password  = var.aws_database_password
}

module "aws_s3" {
  source = "./modules/aws/s3"
  
  bucket_name = "${var.environment}-terraform-state"
}

# GCP Infrastructure
module "gcp_vpc" {
  source = "./modules/gcp/vpc"
  
  project_id   = var.gcp_project_id
  vpc_name     = "${var.environment}-vpc"
  subnet_cidrs = var.gcp_subnet_cidrs
}

module "gcp_gke" {
  source = "./modules/gcp/gke"
  
  cluster_name     = "${var.environment}-gke-cluster"
  project_id       = var.gcp_project_id
  vpc_id          = module.gcp_vpc.vpc_id
  subnet_id       = module.gcp_vpc.subnet_ids[0]
  node_count      = var.gcp_gke_node_count
  machine_type    = var.gcp_gke_machine_type
}

module "gcp_cloudsql" {
  source = "./modules/gcp/cloudsql"
  instance_name    = "${var.environment}-postgres"
  project_id       = var.gcp_project_id
  database_version = "POSTGRES_14"
  tier            = var.gcp_cloudsql_tier
  database_name   = var.gcp_database_name
  username        = var.gcp_database_username
  password        = var.gcp_database_password
}