resource "google_cloud_scheduler_job" "basic_classify_job" {
  name        = "basic-classify-job"
  description = "Run Basic Classify cloud function"

  schedule  = "0 6 * * *"
  time_zone = "Australia/Sydney"

  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = var.basic_classify_url

    oidc_token {
      service_account_email = var.service_account_email
    }
  }
}

resource "google_cloud_scheduler_job" "bigquery_classify_job" {
  name        = "bigquery-classify-job"
  description = "Run BigQuery Classify cloud function"

  schedule  = "0 6 * * *"
  time_zone = "Australia/Sydney"

  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "GET"
    uri         = var.bigquery_classify_url

    oidc_token {
      service_account_email = var.service_account_email
    }
  }
}