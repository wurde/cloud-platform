module "cloud_aws" {
  source = "./modules/cloud-aws"
  count  = var.cloud == "aws" ? 1 : 0

  region = var.region
}
