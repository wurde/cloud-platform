module "gcp-cloud" {
  source = "./modules/gcp-cloud"
  count  = var.cloud == "gcp" ? 1 : 0
}
