module "cloud-storage" {
    source = "./modules/cloud-storage"
    gcp_project = var.gcp_project
    gcp_region = var.gcp_region

    depends_on = [
      module.service-apis
    ]
}

module "cloud-scheduler" {
    source = "./modules/cloud-scheduler"
    gcp_project = var.gcp_project
    gcp_region = var.gcp_region

    depends_on = [
      module.cloud-functions
    ]

    basic_classify_url = module.cloud-functions.basic_classify_function_uri
    service_account_email = module.cloud-functions.basic_classify_service_account
}

module "cloud-functions" {
    source = "./modules/cloud-functions"
    gcp_project = var.gcp_project
    gcp_region = var.gcp_region

    depends_on = [
      module.cloud-storage
    ]

    basic_classify_bucket = module.cloud-storage.function_bucket_basic_classify
    basic_classify_object = module.cloud-storage.function_object_basic_classify
    nl_api_key_secret = module.service-apis.nl_api_secret_id
}

module "service-apis" {
    source = "./modules/service-apis"
    gcp_project = var.gcp_project
    gcp_service_list = var.gcp_service_list
}