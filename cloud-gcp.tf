module "gcp_cloud" {
  source = "./modules/cloud-gcp"
  count  = var.cloud == "gcp" ? 1 : 0
}
