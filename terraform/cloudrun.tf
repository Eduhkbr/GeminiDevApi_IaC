resource "google_cloud_run_service" "default" {
  project  = var.gcp_project_id
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
      service_account_name = google_service_account.cloud_run_sa.email
      containers {
        image = var.image_url

        env {
          name  = "SPRING_PROFILES_ACTIVE"
          value = "prod"
        }
        env {
          name  = "DEVAPI_DB_URL"
          value = "jdbc:postgresql:///${google_sql_database.default.name}?cloudSqlInstance=${google_sql_database_instance.default.connection_name}&socketFactory=com.google.cloud.sql.postgres.SocketFactory"
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
          value = tostring(google_redis_instance.default.port)
        }
        env {
          name  = "REDIS_USER"
          value = var.db_user
        }
        env {
          name  = "REDIS_PASSWORD"
          value = var.db_password
        }
      }
    }
  }

  autogenerate_revision_name = true
  depends_on = [google_project_service.apis]
}

# Permite que o serviço seja invocado publicamente (sem login do Google)
resource "google_cloud_run_service_iam_member" "allow_public" {
  project  = google_cloud_run_service.default.project
  location = google_cloud_run_service.default.location
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}