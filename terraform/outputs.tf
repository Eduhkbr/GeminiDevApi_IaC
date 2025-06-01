output "db_private_ip_address" {
  value = google_sql_database_instance.default.private_ip_address
}

output "redis_host" {
  value = google_redis_instance.default.host
}
output "cloudrun_url" {
  value = google_cloud_run_service.default.status[0].url
}
