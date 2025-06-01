variable "gcp_project_id" {
  type        = string
  description = "The ID of the GCP project"
}

variable "gcp_region" {
  type        = string
  description = "The region to deploy resources in"
  default     = "us-central1"
}

variable "db_instance_name" {
  type        = string
  description = "The name for the Cloud SQL instance"
  default     = "devapi-db"
}

variable "db_name" {
  type        = string
  description = "The name of the database"
  default     = "devapi_db"
}

variable "db_user" {
  type        = string
  description = "The database user"
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "The database password"
  sensitive   = true
}

variable "redis_instance_name" {
  type        = string
  description = "The name for the Redis instance"
  default     = "devapi-redis"
}

variable "cloudrun_service_name" {
  type        = string
  description = "The name for the Cloud Run service"
  default     = "devapi-service"
}

variable "image_url" {
  type        = string
  description = "URL da imagem docker no Artifact Registry"
}
