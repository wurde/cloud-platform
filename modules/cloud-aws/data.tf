# Data sources allow Terraform use information defined
# outside of Terraform, defined by another separate Terraform
# configuration, or modified by functions.
#
# https://www.terraform.io/docs/language/data-sources/index.html

# Current AWS partition.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition
data "aws_partition" "current" {}

# List of AWS Availability Zones for the current region.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones
data "aws_availability_zones" "available" {}

data "http" "wait_for_cluster" {
  url            = format("%s/healthz", local.cluster_endpoint)
  ca_certificate = base64decode(local.cluster_auth_base64)
  timeout        = "300"

  depends_on = [
    aws_eks_cluster.main,
    aws_security_group_rule.cluster_private_access_sg_source,
    aws_security_group_rule.cluster_private_access_cidrs_source,
  ]
}
