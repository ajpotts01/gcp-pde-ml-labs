variable "gcp_project" {
  type        = string
  description = "Your GCP project ID"
}

variable "gcp_service_list" {
  description = "List of GCP services"
  type        = list(any)
}