module "cloud-storage" {
    source = "./modules/cloud-storage"
    gcp_project = var.gcp_project
    gcp_region = var.gcp_region

    depends_on = [
      module.service-apis
    ]
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
}

module "service-apis" {
    source = "./modules/service-apis"
    gcp_project = var.gcp_project
    gcp_service_list = var.gcp_service_list
}