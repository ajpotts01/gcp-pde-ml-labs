resource "google_service_account" "functions_sa" {
    account_id = "gcf-sa"
    display_name = "Cloud Functions Managed Service Account"
}

resource "google_cloudfunctions2_function" "basic_classify_function" {
    name = "basic-classify-function"
    project = var.gcp_project
    location = var.gcp_region

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
      ingress_settings = "ALLOW_INTERNAL_ONLY"
      all_traffic_on_latest_revision = true
      service_account_email = google_service_account.functions_sa.email

      environment_variables = {
        GOOGLE_FUNCTION_SOURCE = "basic_classify.py"
      }
    }
}

output "basic_classify_function_uri" {
    value = google_cloudfunctions2_function.basic_classify_function.service_config[0].uri
}