output "bucket_name" {
  value       = google_storage_bucket.static_upload.name
  description = "The name of the GCS bucket"
}

output "bucket_url" {
  value       = google_storage_bucket.static_upload.url
  description = "The URL of the GCS bucket"
}

output "bucket_id" {
  value       = google_storage_bucket.static_upload.id
  description = "The ID of the GCS bucket"
}
