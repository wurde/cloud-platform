# Amazon Virtual Private Cloud (VPC)
# https://aws.amazon.com/vpc

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  public_subnets  = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = false # TEMP true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

# Security groups for your VPC
# A security group acts as a virtual firewall for your
# instance to control inbound and outbound traffic.
# https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "cluster" {
  name_prefix = var.cluster_name
  description = "EKS cluster security group."
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-eks_cluster_sg"
    },
  )
}

# resource "aws_security_group_rule" "cluster_private_access_sg_source" {
#   count = var.cluster_create_endpoint_private_access_sg_rule && var.cluster_endpoint_private_access && var.cluster_endpoint_private_access_sg != null ? length(var.cluster_endpoint_private_access_sg) : 0

#   description              = "Allow private K8S API ingress from custom Security Groups source."
#   type                     = "ingress"
#   from_port                = 443
#   to_port                  = 443
#   protocol                 = "tcp"
#   source_security_group_id = var.cluster_endpoint_private_access_sg[count.index]

#   security_group_id = aws_eks_cluster.main[0].vpc_config[0].cluster_security_group_id
# }

# resource "aws_security_group" "worker_group_mgmt_one" {
#   name_prefix = "worker_group_mgmt_one"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#     ]
#   }
# }

# resource "aws_security_group" "worker_group_mgmt_two" {
#   name_prefix = "worker_group_mgmt_two"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "192.168.0.0/16",
#     ]
#   }
# }

# resource "aws_security_group" "all_worker_mgmt" {
#   name_prefix = "all_worker_management"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "10.0.0.0/8",
#       "172.16.0.0/12",
#       "192.168.0.0/16",
#     ]
#   }
# }
