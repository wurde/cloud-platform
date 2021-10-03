module "aws_cloud" {
  source = "./modules/aws-cloud"
  count  = var.cloud == "aws" ? 1 : 0

  region = var.region
}
