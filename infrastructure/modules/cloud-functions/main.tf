resource "google_service_account" "functions_sa" {
    account_id = "gcf-sa"
    display_name = "Cloud Functions Managed Service Account"
}

resource "google_secret_manager_secret_iam_binding" "functions_sa_secret_binding"  {
    project = var.gcp_project
    secret_id = var.nl_api_key_secret
    role = "roles/secretmanager.secretAccessor"
    members = [
        "serviceAccount:${google_service_account.functions_sa.email}"
    ]
}

resource "google_cloudfunctions2_function_iam_binding" "functions_sa_invocation_binding"  {
    project = var.gcp_project
    location = var.gcp_region
    cloud_function = google_cloudfunctions2_function.basic_classify_function.name
    role = "roles/cloudfunctions.invoker"
    members = [
        "serviceAccount:${google_service_account.functions_sa.email}"
    ]
}

# Note: Even though GCP Cloud Functions Gen2 presents as a cloud function,
# with its own Terraform IAM resources etc. it is essentially an abstracted
# Cloud Run service. So a Cloud Run service binding for the function is required.
# This probably makes the above function binding redundant, as it won't work on its own.
resource "google_cloud_run_service_iam_binding" "functions_sa_run_invocation_binding" {
    project = var.gcp_project
    location = var.gcp_region
    service = google_cloudfunctions2_function.basic_classify_function.name
    role = "roles/run.invoker"
    members = [
        "serviceAccount:${google_service_account.functions_sa.email}"
    ]    
}

resource "google_cloudfunctions2_function" "basic_classify_function" {
    name = "basic-classify-function"
    project = var.gcp_project
    location = var.gcp_region

    depends_on = [
      google_service_account.functions_sa,
      google_secret_manager_secret_iam_binding.functions_sa_secret_binding
    ]

    build_config {
        runtime = "python38" # This was developed using a venv with 3.7.9        
        entry_point = "run"
        environment_variables = {
          GOOGLE_FUNCTION_SOURCE = "basic_classify.py"
        }

        source {
            storage_source {
              bucket = var.basic_classify_bucket
              object = var.basic_classify_object
            }
        }  
    }

    service_config {
      max_instance_count = 1
      available_memory = "256M"
      timeout_seconds = 120
      ingress_settings = "ALLOW_ALL" # Figure out if this can be ALLOW_INTERNAL_ONLY? ALLOW_ALL doesn't open the gates, but still feels too open
      all_traffic_on_latest_revision = true
      service_account_email = google_service_account.functions_sa.email

      environment_variables = {
        GOOGLE_FUNCTION_SOURCE = "basic_classify.py"
      }

      secret_environment_variables {
        key = "NL_API_KEY"
        project_id = var.gcp_project
        secret = var.nl_api_key_secret
        version = "latest"
      }
    }
}

output "basic_classify_function_uri" {
    value = google_cloudfunctions2_function.basic_classify_function.service_config[0].uri
}

output "basic_classify_service_account" {
    value = google_service_account.functions_sa.email
}