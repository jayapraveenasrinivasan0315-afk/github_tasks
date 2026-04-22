module "artifact_repo" {
  source        = "./modules/artifact-repo"
  repository_id = var.repository_id
  description   = var.description
  labels        = var.labels
  project_id    = var.project_id
  region        = var.region
}

module "gcs" {
  source             = "./modules/gcs"
  bucket_name        = var.bucket_name
  region             = var.region
  force_destroy      = var.force_destroy
  enable_versioning  = var.enable_versioning
  enable_public_read = var.enable_public_read
  labels             = var.labels
}

module "cloud_run" {
  source       = "./modules/cloud-run"
  service_name = var.service_name
  image        = var.image
  project_id   = var.project_id
  region       = var.region
}
