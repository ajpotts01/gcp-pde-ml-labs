resource "random_id" "gcs_bucket_prefix" {
    byte_length = 8
}

data "archive_file" "basic_classify_function_src" {
    type = "zip"

    # IMPORTANT NOTE:
    # When archiving source for... anything, the directory path is relative to
    # the calling main.tf file, NOT the module source. So in this case it's
    # infrastructure/main.tf, not infrastructure/modules/etc.
    source_dir = "../functions/basic-classify/src"
    output_path = "../functions/basic-classify/build/basic_classify.zip"
}

resource "google_storage_bucket" "basic_classify_function" {
    name = "${random_id.gcs_bucket_prefix.hex}-basic-classify-function"
    location = var.gcp_region
    project = var.gcp_project
    storage_class = "STANDARD"
    uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "basic_classify_function_object" {
    source = data.archive_file.basic_classify_function_src.output_path
    content_type = "application/zip"

    name = "src-${data.archive_file.basic_classify_function_src.output_md5}.zip"
    bucket = google_storage_bucket.basic_classify_function.name

    depends_on = [
      google_storage_bucket.basic_classify_function,
      data.archive_file.basic_classify_function_src
    ]
}

output "function_bucket_basic_classify" {
    value = google_storage_bucket.basic_classify_function.name
}

output "function_object_basic_classify" {
    value = google_storage_bucket_object.basic_classify_function_object.name
}