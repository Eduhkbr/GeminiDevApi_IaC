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
  }
}

resource "google_sql_database" "default" {
  name     = var.db_name
  instance = google_sql_database_instance.default.name
}

resource "google_redis_instance" "default" {
  name           = var.redis_instance_name
  tier           = "BASIC"
  memory_size_gb = 1
  region         = var.gcp_region
}

resource "google_cloud_run_service" "default" {
  name     = var.cloudrun_service_name
  location = var.gcp_region

  template {
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
