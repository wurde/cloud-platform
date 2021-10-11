module "cloud_aws" {
  source = "./modules/cloud-aws"
  count  = var.cloud == "aws" ? 1 : 0

  cluster_version               = var.cluster_version
  cluster_enabled_log_types     = var.cluster_enabled_log_types
  cluster_log_retention_in_days = var.cluster_log_retention_in_days
  cluster_log_kms_key_id        = var.cluster_log_kms_key_id

  node_groups          = var.node_groups
  node_groups_defaults = var.node_groups_defaults

  map_iam_roles    = var.map_iam_roles
  map_iam_users    = var.map_iam_users
  map_aws_accounts = var.map_aws_accounts

  region = var.region
  tags   = var.tags
}
