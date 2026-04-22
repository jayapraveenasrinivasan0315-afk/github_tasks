output "docker_repo" {
  value       = google_artifact_registry_repository.docker_repo
  description = "The Artifact Registry Docker repository"
}

output "repository_id" {
  value       = google_artifact_registry_repository.docker_repo.repository_id
  description = "The ID of the Artifact Registry repository"
}

output "repository_url" {
  value       = google_artifact_registry_repository.docker_repo.repository_url
  description = "The URL of the Artifact Registry repository"
}
