module "service-apis" {
    source = "./service-apis"
    gcp_project = var.gcp_project
    gcp_service_list = var.gcp_service_list
}