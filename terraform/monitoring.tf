resource "google_compute_instance" "grafana_vm" {
  project      = var.gcp_project_id
  zone         = var.gcp_zone
  name         = "grafana-server"
  machine_type = "e2-small"
  tags         = ["grafana-web"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.main.id
    subnetwork = google_compute_subnetwork.main.id
    access_config {}
  }

  metadata_startup_script = templatefile("${path.module}/scripts/install_grafana.sh.tpl", {
    prometheus_datasource_yml = templatefile("${path.module}/../grafana/provisioning/datasources/prometheus-datasource.yml", { GCP_PROJECT_ID = var.gcp_project_id })
    dashboard_provider_yml    = file("${path.module}/../grafana/provisioning/dashboards/dashboard-provider.yml")
    api_dashboard_json        = file("${path.module}/../grafana/dashboards/api_dashboards.json")
  })

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  depends_on = [google_project_service.apis]
}