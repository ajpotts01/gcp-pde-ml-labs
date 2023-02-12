resource "google_service_account" "bigquery_sa" {
  account_id   = "bigquery-sa"
  display_name = "BigQuery Managed Service Account"
}

resource "google_bigquery_dataset" "news_classification_dataset" {
  dataset_id    = "news_classification_dataset"
  friendly_name = "news_classification"
  description   = "For news classification demos from GCP labs"
  location      = var.gcp_region
  project       = var.gcp_project

}

resource "google_bigquery_dataset_iam_member" "news_classification_iam_owner" {
  project    = var.gcp_project
  dataset_id = google_bigquery_dataset.news_classification_dataset.dataset_id
  role       = "roles/bigquery.admin"

  member = "serviceAccount:${google_service_account.bigquery_sa.email}"
}

resource "google_bigquery_table_iam_member" "article_data_iam_owner" {
  project    = var.gcp_project
  dataset_id = google_bigquery_dataset.news_classification_dataset.dataset_id
  table_id   = google_bigquery_table.article_data.table_id

  role   = "roles/bigquery.admin"
  member = "serviceAccount:${google_service_account.bigquery_sa.email}"
}

resource "google_bigquery_table" "article_data" {
  dataset_id = "news_classification_dataset"
  table_id   = "article_data"

  project = var.gcp_project

  # Click Add Field and add the following 3 fields: article_text with type STRING, category with type STRING, and confidence with type FLOAT.
  schema = <<EOF
    [
        {
            "name": "article_text",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "The article text that's being classified"
        },
        {
            "name": "category",
            "type": "STRING",
            "mode": "NULLABLE",
            "description": "Category from the classifier"
        },
        {
            "name": "confidence",
            "type": "FLOAT",
            "mode": "NULLABLE",
            "description": "Confidence reported by the classifier"
        }                
    ]
    EOF

  depends_on = [
    google_bigquery_dataset_iam_member.news_classification_iam_owner
  ]

}