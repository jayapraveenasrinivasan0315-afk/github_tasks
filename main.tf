module "api_enablement" {
  source     = "./modules/api-enablement"
  project_id = var.project_id
}

module "artifact_repo" {
  source        = "./modules/artifact-repo"
  repository_id = var.repository_id
  description   = var.description
  labels        = var.labels
  project_id    = var.project_id
  region        = var.region
  depends_on    = [module.api_enablement]
}

module "gcs" {
  source             = "./modules/gcs"
  bucket_name        = var.bucket_name
  region             = var.region
  force_destroy      = var.force_destroy
  enable_versioning  = var.enable_versioning
  enable_public_read = var.enable_public_read
  labels             = var.labels
  depends_on         = [module.api_enablement]
}

module "cloud_run" {
  source       = "./modules/cloud-run"
  service_name = var.service_name
  image        = var.image
  project_id   = var.project_id
  region       = var.region
  depends_on   = [module.api_enablement]
}
