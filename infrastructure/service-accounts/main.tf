resource "google_service_account" "infrastructure_sa" {
    account_id = "infrastructure-sa"
    display_name = "A service account for spinning up Terraform infrastructure"
}