resource "google_service_account" "cloud_run_sa" {
  project      = var.gcp_project_id
  account_id   = "geminidevapi-cloudrun-sa"
  display_name = "Service Account for GeminiDevApi Cloud Run"
}

# Permite que o Cloud Run acesse o Secret Manager (se você usar), Cloud SQL, etc.
resource "google_project_iam_member" "cloudrun_roles" {
  for_each = toset([
    "roles/run.invoker",
    "roles/cloudsql.client",
    "roles/monitoring.metricWriter" # Permissão para escrever métricas para o Prometheus
  ])

  project = var.gcp_project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Permissão para que a VM do Grafana use a conta de serviço padrão do GCE para autenticar
resource "google_project_iam_member" "gce_monitoring_viewer" {
  project = var.gcp_project_id
  role    = "roles/monitoring.viewer"
  # Usa a conta de serviço padrão do Compute Engine
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

# Pega a conta de serviço padrão do GCE para não precisar criá-la
data "google_compute_default_service_account" "default" {
  project = var.gcp_project_id
}