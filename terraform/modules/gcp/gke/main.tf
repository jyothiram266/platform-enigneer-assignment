resource "google_container_cluster" "main" {
  name               = var.cluster_name
  location           = var.region
  network           = var.vpc_id
  subnetwork        = var.subnet_id
  project           = var.project_id

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "main" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.main.name
  project    = var.project_id
  node_count = var.node_count

  node_config {
    machine_type = var.machine_type

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  autoscaling {
    min_node_count = 1
    max_node_count = var.node_count * 2
  }
}