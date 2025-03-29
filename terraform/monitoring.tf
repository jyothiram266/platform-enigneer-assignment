resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "eks-logs"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}

resource "google_storage_bucket" "gke_logs" {
  name          = "${var.environment}-gke-logs"
  location      = var.gcp_region
  force_destroy = false

  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
}

resource "google_logging_project_sink" "gke_logs" {
  name        = "gke-logs"
  description = "GKE cluster logs sink"
  
  destination = "storage.googleapis.com/${google_storage_bucket.gke_logs.name}"
  
  filter = "resource.type = k8s_container"

  unique_writer_identity = true
}

resource "google_storage_bucket_iam_binding" "gke_logs" {
  bucket = google_storage_bucket.gke_logs.name
  role   = "roles/storage.objectViewer"
  
  members = [
    google_logging_project_sink.gke_logs.writer_identity,
  ]
}