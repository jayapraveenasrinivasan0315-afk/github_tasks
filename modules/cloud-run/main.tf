resource "google_cloud_run_v2_service" "service" {
  name     = var.service_name
  location = var.region
  project  = var.project_id
  
  template {
    containers {
      image = var.image
    }
  }
}