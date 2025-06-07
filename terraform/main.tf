terraform {
  backend "gcs" {
    bucket = "geminiapiterraformbucket"
    prefix = "terraform/state"
  }
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

# Habilita as APIs necessárias para o projeto
resource "google_project_service" "apis" {
  for_each = toset([
    "sqladmin.googleapis.com",
    "redis.googleapis.com",
    "vpcaccess.googleapis.com",
    "run.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "monitoring.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])

  project            = var.gcp_project_id
  service            = each.key
  disable_on_destroy = false
}