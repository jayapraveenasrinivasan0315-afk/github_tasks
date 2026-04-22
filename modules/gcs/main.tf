resource "google_storage_bucket" "static_upload" {
  name          = var.bucket_name
  location      = var.region
  force_destroy = var.force_destroy

  versioning {
    enabled = var.enable_versioning
  }

  uniform_bucket_level_access = true

  labels = var.labels
}

resource "google_storage_bucket_iam_member" "public_read" {
  count  = var.enable_public_read ? 1 : 0
  bucket = google_storage_bucket.static_upload.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
