variable "bucket_name" {
  description = "The name of the GCS bucket"
  type        = string
}

variable "region" {
  description = "The region to deploy the bucket"
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

variable "labels" {
  description = "Labels to apply to the bucket"
  type        = map(string)
  default = {
    purpose = "static-upload"
  }
}
