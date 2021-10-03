# Amazon Virtual Private Cloud (VPC)
# https://aws.amazon.com/vpc

# resource "aws_security_group_rule" "cluster_private_access_sg_source" {
#   count = var.create_eks && var.cluster_create_endpoint_private_access_sg_rule && var.cluster_endpoint_private_access && var.cluster_endpoint_private_access_sg != null ? length(var.cluster_endpoint_private_access_sg) : 0

#   description              = "Allow private K8S API ingress from custom Security Groups source."
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   source_security_group_id = var.cluster_endpoint_private_access_sg[count.index]

#   security_group_id = aws_eks_cluster.this[0].vpc_config[0].cluster_security_group_id
# }
