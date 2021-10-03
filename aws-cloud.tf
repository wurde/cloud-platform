module "aws-cloud" {
  source = "./modules/aws-cloud"
  count  = var.cloud == "aws" ? 1 : 0
}
