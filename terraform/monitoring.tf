
resource "google_monitoring_workspace" "primary" {
  project = var.gcp_project_id
}

resource "google_monitoring_monitored_project" "prometheus_project" {
  metrics_scope = google_monitoring_workspace.primary.name
  name          = var.gcp_project_id
}

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
    access_config {
      // Cria um IP externo para acessar o Grafana
    }
  }

  metadata_startup_script = <<-EOT
    sleep 10
    
    # Instalação do Grafana
    sudo apt-get update
    sudo apt-get install -y apt-transport-https wget
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    sudo apt-get update
    sudo apt-get install -y grafana

    # Provisionamento da fonte de dados e do dashboard
    sudo mkdir -p /etc/grafana/provisioning/datasources
    sudo mkdir -p /etc/grafana/provisioning/dashboards
    
    # Injeção da configuração da fonte de dados
    cat <<EOF | sudo tee /etc/grafana/provisioning/datasources/prometheus.yml
${file("../grafana/provisioning/datasources/prometheus-datasource.yml")}
EOF
    
    # Injeção da configuração do provedor de dashboards
    cat <<EOF | sudo tee /etc/grafana/provisioning/dashboards/dashboards.yml
${file("../grafana/provisioning/dashboards/dashboard-provider.yml")}
EOF
    
    # Injeção do dashboard JSON
    sudo mkdir -p /var/lib/grafana/dashboards
    cat <<EOF | sudo tee /var/lib/grafana/dashboards/api_dashboard.json
${file("../grafana/dashboards/api_dashboard.json")}
EOF
    
    # Restart do Grafana para aplicar as configurações
    sudo systemctl daemon-reload
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server.service
  EOT

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
  
  depends_on = [google_project_service.apis]
}