terraform {
  backend "gcs" {
    bucket = "111b735191e9bd6d-bucket-tfstate"
    prefix = "terraform/state"
  }
}