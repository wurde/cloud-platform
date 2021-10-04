# Data sources allow Terraform use information defined
# outside of Terraform, defined by another separate Terraform
# configuration, or modified by functions.
#
# https://www.terraform.io/docs/language/data-sources/index.html

# data "http" "wait_for_cluster" {
#   count = var.cloud == "aws" ? 1 : 0

#   url            = format("%s/healthz", module.aws_cloud.aws_eks_cluster.main[0].endpoint)
#   ca_certificate = base64decode(local.cluster_auth_base64)
#   timeout        = var.wait_for_cluster_timeout

#   depends_on = [
#     module.aws_cloud.aws_eks_cluster.main,
#     aws_security_group_rule.cluster_private_access_sg_source,
#     aws_security_group_rule.cluster_private_access_cidrs_source,
#   ]
# }
