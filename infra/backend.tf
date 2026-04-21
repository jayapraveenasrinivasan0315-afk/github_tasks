terraform {
  backend "gcs" {
    bucket = "github_task_1"
    prefix = "dev/terraform"
  }
}
