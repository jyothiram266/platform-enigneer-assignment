resource "google_sql_database_instance" "main" {
  name             = var.instance_name
  database_version = var.database_version
  project          = var.project_id
  region           = var.region

  settings {
    tier = var.tier

    backup_configuration {
      enabled = true
    }

    ip_configuration {
      ipv4_enabled = false
      private_network = var.vpc_id
    }
  }

  deletion_protection = true
}

resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
  project  = var.project_id
}

resource "google_sql_user" "user" {
  name     = var.username
  instance = google_sql_database_instance.main.name
  password = var.password
  project  = var.project_id
}