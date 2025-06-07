resource "google_compute_network" "main" {
  project                 = var.gcp_project_id
  name                    = "devapi-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.apis]
}

resource "google_compute_subnetwork" "main" {
  project       = var.gcp_project_id
  name          = "devapi-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.gcp_region
  network       = google_compute_network.main.id
}

resource "google_compute_global_address" "private_ip_range" {
  project       = var.gcp_project_id
  name          = "devapi-private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_range.name]
}

resource "google_vpc_access_connector" "connector" {
  project       = var.gcp_project_id
  name          = "devapi-connector"
  region        = var.gcp_region
  network       = google_compute_network.main.id
  ip_cidr_range = "10.8.0.0/28"
  depends_on    = [google_project_service.apis]
}

resource "google_compute_firewall" "allow_grafana" {
  project = var.gcp_project_id
  name    = "allow-grafana-ingress"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["3000"]
  }

  source_ranges = ["0.0.0.0/0"] # Para produção, restrinja isso para o seu IP.
  target_tags   = ["grafana-web"]
}