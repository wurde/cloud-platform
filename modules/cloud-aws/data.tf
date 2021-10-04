# Data sources allow Terraform use information defined
# outside of Terraform, defined by another separate Terraform
# configuration, or modified by functions.
#
# https://www.terraform.io/docs/language/data-sources/index.html

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition
data "aws_partition" "current" {}
