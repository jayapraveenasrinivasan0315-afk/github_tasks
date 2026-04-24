project_id = "gwx-devops-internship"
region = "asia-south1"
image = "gcr.io/google-samples/hello-app:1.0"
bucket_name = "github-tf-bucket"
repository_id = "github-repo"
description = "GitHub Terraform Repository"
service_name = "github-tf-service"
labels = {
  environment = "dev"
  project     = "github-tf-tasks"
}
force_destroy = true
enable_versioning = true
enable_public_read = false
