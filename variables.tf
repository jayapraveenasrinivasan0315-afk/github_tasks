variable "project_id" {
  description = "The project ID to deploy resources"
  type        = string
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
}

variable "image" {
  description = "The image to deploy"
  type        = string
}

variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "repository_id" {
  description = "The Artifact Registry repository ID"
  type        = string
}

variable "description" {
  description = "Description for the Artifact Registry repository"
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    environment = "dev"
  }
}

variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
}

variable "force_destroy" {
  description = "Allow destruction of bucket with contents"
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable versioning on the bucket"
  type        = bool
  default     = true
}

variable "enable_public_read" {
  description = "Enable public read access to bucket"
  type        = bool
  default     = false
}