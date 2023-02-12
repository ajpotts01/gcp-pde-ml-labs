variable "gcp_project" {
  type        = string
  description = "Your GCP project ID"
}

variable "gcp_region" {
  type        = string
  description = "Your preferred/default GCP region"
}

variable "gcp_service_list" {
  type        = list(any)
  description = "List of GCP services"
}