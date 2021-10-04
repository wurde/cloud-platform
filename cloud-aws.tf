module "cloud_aws" {
  source = "./modules/cloud-aws"
  count  = var.cloud == "aws" ? 1 : 0

  cluster_version = var.cluster_version

  worker_groups                 = var.worker_groups
  workers_group_defaults        = var.workers_group_defaults
  worker_groups_launch_template = var.worker_groups_launch_template

  region = var.region
  tags   = var.tags
}
