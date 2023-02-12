variable "gcp_project" {
  type        = string
  description = "Your GCP project ID"
}

variable "gcp_region" {
  type        = string
  description = "Your preferred/default GCP region"
}

variable "basic_classify_url" {
  type        = string
  description = "URL of basic-classify cloud function"
}

variable "bigquery_classify_url" {
  type = string
  description = "URL of bigquery-classify cloud function"
}

variable "service_account_email" {
  type        = string
  description = "Service account e-mail to use for OAuth"
}