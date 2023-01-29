terraform {
    required_providers {
      google = {
        source = "hashicorp/google"
        version = "~> 4.50"
      }
    }
}

provider google {
    region = var.gcp_region
    project = var.gcp_project
}