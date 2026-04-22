terraform {
  backend "gcs" {
    bucket = ""        # intentionally left empty
    prefix = "development/terraform.tfstate"
  }
}