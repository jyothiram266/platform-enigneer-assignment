resource "google_compute_network" "main" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnets" {
  count         = length(var.subnet_cidrs)
  name          = "${var.vpc_name}-subnet-${count.index + 1}"
  ip_cidr_range = var.subnet_cidrs[count.index]
  network       = google_compute_network.main.id
  region        = var.region
  project       = var.project_id

  private_ip_google_access = true
}