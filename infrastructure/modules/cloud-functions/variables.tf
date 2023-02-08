variable "gcp_project" {
    type = string
    description = "Your GCP project ID"
}

variable "gcp_region" {
    type = string
    description = "Your preferred/default GCP region"
}

variable "basic_classify_bucket" {
    type = string
    description = "Bucket for basic classify function"
}

variable "basic_classify_object" {
    type = string
    description = "Object name for basic classify function source"
}

variable "nl_api_key_secret" {
    type = string
    description = "NL API key secret - for setting up as environment variable"
}