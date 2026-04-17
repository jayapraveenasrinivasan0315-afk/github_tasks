provider "google" {
  project = var.project_id
  region  = var.region
}
resource "google_storage_bucket" "my_bucket" {
  name     = var.bucket_name
  location = var.region
}
resource "google_cloud_run_v2_service" "default" {
  name     = "my-service"
  location = var.region
  template {
    containers {
      image = var.image
    }
  }
}
