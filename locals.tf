# locals {
#   cluster_id          = coalescelist(module.aws_cloud.aws_eks_cluster.this[*].id, [""])[0]
#   cluster_auth_base64 = coalescelist(module.aws_cloud.aws_eks_cluster.this[*].certificate_authority[0].data, [""])[0]
# }
