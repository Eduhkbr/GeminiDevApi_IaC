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

  # Script que instala e configura o Grafana na inicialização da VM
  metadata_startup_script = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y apt-transport-https wget
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
    sudo apt-get update
    sudo apt-get install -y grafana

    # Provisiona a fonte de dados e o dashboard
    sudo mkdir -p /etc/grafana/provisioning/datasources
    sudo mkdir -p /etc/grafana/provisioning/dashboards
    
    cat <<'EOF' | sudo tee /etc/grafana/provisioning/datasources/prometheus.yml
    ${file("../grafana/provisioning/datasources/prometheus-datasource.yml")}
    EOF
    
    cat <<'EOF' | sudo tee /etc/grafana/provisioning/dashboards/dashboards.yml
    ${file("../grafana/provisioning/dashboards/dashboard-provider.yml")}
    EOF
    
    sudo mkdir -p /var/lib/grafana/dashboards
    cat <<'EOF' | sudo tee /var/lib/grafana/dashboards/api_dashboard.json
    ${file("../grafana/dashboards/api_dashboard.json")}
    EOF
    
    sudo systemctl daemon-reload
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server.service
  EOT

  service_account {
    # Usa a conta de serviço padrão do GCE, que já tem permissão de viewer do monitoring
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

# Configura o projeto para usar o Prometheus Gerenciado
resource "google_monitoring_monitored_project" "prometheus_project" {
  project                  = var.gcp_project_id
  name                     = var.gcp_project_id
  metric_container_project = var.gcp_project_id
}