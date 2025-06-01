output "db_public_ip_address" {
  value = google_sql_database_instance.default.public_ip_address
}

output "cloudrun_url" {
  value = google_cloud_run_service.default.status[0].url
}
