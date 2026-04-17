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