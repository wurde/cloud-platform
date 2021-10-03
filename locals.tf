# locals {
#   cluster_id          = coalescelist(module.cloud_aws.aws_eks_cluster.this[*].id, [""])[0]
#   cluster_name        = coalescelist(module.cloud_aws.aws_eks_cluster.this[*].name, [""])[0]
#   cluster_auth_base64 = coalescelist(module.cloud_aws.aws_eks_cluster.this[*].certificate_authority[0].data, [""])[0]
# }

# cluster_name = "eks-${random_string.suffix.result}"
# resource "random_string" "suffix" {
#   length  = 8
#   special = false
# }
