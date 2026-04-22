# Artifact Registry Repository Outputs
output "artifact_repository_id" {
  value       = module.artifact_repo.docker_repo.repository_id
  description = "The ID of the Artifact Registry repository"
}

# GCS Bucket Outputs
output "bucket_name" {
  value       = module.gcs.bucket_name
  description = "The name of the GCS bucket"
}

output "bucket_url" {
  value       = module.gcs.bucket_url
  description = "The URL of the GCS bucket"
}

output "bucket_id" {
  value       = module.gcs.bucket_id
  description = "The ID of the GCS bucket"
}

# Cloud Run Service Outputs
output "cloud_run_service_url" {
  value       = module.cloud_run.service_url
  description = "The URL of the Cloud Run service"
}

output "cloud_run_service_name" {
  value       = module.cloud_run.service_name
  description = "The name of the Cloud Run service"
}
