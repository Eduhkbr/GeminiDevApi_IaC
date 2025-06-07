resource "google_sql_database_instance" "default" {
  project          = var.gcp_project_id
  name             = var.db_instance_name
  region           = var.gcp_region
  database_version = "POSTGRES_15"
  depends_on       = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }
  }
}

resource "google_sql_database" "default" {
  project  = var.gcp_project_id
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

resource "google_sql_user" "default" {
  project  = var.gcp_project_id
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = var.db_password
}

resource "google_redis_instance" "default" {
  project            = var.gcp_project_id
  name               = var.redis_instance_name
  tier               = "BASIC"
  memory_size_gb     = 1
  region             = var.gcp_region
  authorized_network = google_compute_network.main.id
  depends_on         = [google_service_networking_connection.private_vpc_connection]
}