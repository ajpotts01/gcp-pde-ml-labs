resource "google_project_service" "gcp_services" {
  count                      = length(var.gcp_service_list)
  service                    = var.gcp_service_list[count.index]
  project                    = var.gcp_project
  disable_dependent_services = true
}

resource "google_apikeys_key" "nl_key" {
  name         = "nl-api-key"
  display_name = "natural-language-key"
  project      = var.gcp_project

  depends_on = [
    google_project_service.gcp_services
  ]

}

resource "google_secret_manager_secret" "nl_api_secret" {
  secret_id = "nl_api_secret"

  replication {
    automatic = true
  }

  depends_on = [
    google_project_service.gcp_services
  ]
}

resource "google_secret_manager_secret_version" "nl_api_secret" {
  secret      = google_secret_manager_secret.nl_api_secret.id
  secret_data = google_apikeys_key.nl_key.key_string
}

output "nl_api_secret_id" {
  value = google_secret_manager_secret.nl_api_secret.secret_id
}