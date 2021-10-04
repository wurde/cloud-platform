module "cloud_aws" {
  source = "./modules/cloud-aws"
  count  = var.cloud == "aws" ? 1 : 0

  cluster_version = var.cluster_version

  region = var.region
  tags   = var.tags
}
