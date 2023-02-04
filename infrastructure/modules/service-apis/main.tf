resource "google_project_service" "gcp_services" {
    count = length(var.gcp_service_list)
    service = var.gcp_service_list[count.index]
    project = var.gcp_project
    disable_dependent_services = true
}

resource "google_apikeys_key" "nl_key" {
    name = "nl-key"
    display_name = "natural-language-key"
    project = var.gcp_project

}

resource "google_secret_manager_secret" "nl_api_secret" {
    secret_id = "nl_api_secret"

    replication {
      automatic = true
    }
}

resource "google_secret_manager_secret_version" "nl_api_secret" {
    secret = google_secret_manager_secret.nl_api_secret.id
    secret_data = google_apikeys_key.nl_key.key_string
}