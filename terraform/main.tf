resource "google_sql_user" "default" {
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = var.db_password
}
resource "google_compute_network" "main" {
  name                    = "devapi-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "devapi-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.main.id
}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

resource "google_project_service" "cloudsql" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_sql_database_instance" "default" {
  name             = var.db_instance_name
  region           = var.gcp_region
  database_version = "POSTGRES_15"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
    }
  }
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

resource "google_redis_instance" "default" {
  name               = var.redis_instance_name
  tier               = "BASIC"
  memory_size_gb     = 1
  region             = var.gcp_region
  authorized_network = google_compute_network.main.id
}

resource "google_vpc_access_connector" "connector" {
  name          = "devapi-connector"
  region        = var.gcp_region
  network       = google_compute_network.main.name
  ip_cidr_range = "10.8.0.0/28"
}

resource "google_cloud_run_service" "default" {
  name     = var.cloudrun_service_name
  location = var.gcp_region

  template {
    metadata {
      annotations = {
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.id
        "run.googleapis.com/vpc-access-egress"    = "all-traffic"
      }
    }
    spec {
      containers {
        image = var.image_url
        env {
          name  = "DEVAPI_DB_URL"
          value = "jdbc:postgresql://${google_sql_database_instance.default.name}.${var.gcp_region}.cloudsql.com:5432/${var.db_name}"
        }
        env {
          name  = "DEVAPI_DB_USER"
          value = var.db_user
        }
        env {
          name  = "DEVAPI_DB_PASS"
          value = var.db_password
        }
        env {
          name  = "REDIS_HOST"
          value = google_redis_instance.default.host
        }
        env {
          name  = "REDIS_PORT"
          value = "6379"
        }
        env {
          name  = "REDIS_USER"
          value = var.db_user
        }
        env {
          name  = "REDIS_PASS"
          value = var.db_password
        }
      }
    }
  }

  autogenerate_revision_name = true
}
