# Amazon Virtual Private Cloud (VPC)
# https://aws.amazon.com/vpc

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  name = local.vpc_name
  cidr = local.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  # Subnets associated with your cluster cannot be changed
  # after cluster creation. Do not select a subnet in AWS
  # Outposts, AWS Wavelength, or an AWS Local Zone when
  # creating your cluster.
  public_subnets  = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets = [for k, v in data.aws_availability_zones.available.names : cidrsubnet(local.vpc_cidr, 8, k + 10)]

  enable_nat_gateway   = false # TEMP true
  single_nat_gateway   = true

  # The VPC must have DNS hostname and DNS resolution support,
  # or nodes can't register with the cluster.
  # https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  # Subnet tagging
  #
  # Nodes and load balancers can be launched in any subnet.
  # For Kubernetes load balancing auto discovery to work,
  # subnets must be tagged.
  #
  # https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
  #
  # When you create a Kubernetes Ingress, an AWS Application
  # Load Balancer (ALB) is provisioned that load balances
  # application traffic. To ensure that your Ingress objects
  # use the AWS Load Balancer Controller:
  #
  #   annotations:
  #     kubernetes.io/ingress.class: alb
  #
  # See more:
  # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/ingress/annotations
  #
  # This is so that Kubernetes knows to use only the subnets
  # that were specified for external load balancers.
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  # This is so that Kubernetes and the AWS load balancer
  # controller know that the subnets can be used for internal
  # load balancers.
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
  name_prefix = local.cluster_name
  description = "EKS cluster security group."
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${local.cluster_name}-eks_cluster_sg"
    },
  )
}
resource "aws_security_group_rule" "cluster_egress_internet" {
  description = "Allow cluster egress access to the Internet."

  security_group_id = local.cluster_security_group_id
  cidr_blocks       = var.cluster_egress_cidrs

  from_port = 0
  to_port   = 0
  protocol  = "-1"
  type      = "egress"
}
resource "aws_security_group_rule" "cluster_private_access_cidrs_source" {
  for_each = var.cluster_create_endpoint_private_access_sg_rule && var.cluster_endpoint_private_access && var.cluster_endpoint_private_access_cidrs != null ? toset(var.cluster_endpoint_private_access_cidrs) : []

  description = "Allow private K8S API ingress from custom CIDR source."

  security_group_id = local.cluster_security_group_id
  cidr_blocks       = [each.value]

  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  type      = "ingress"
}
resource "aws_security_group_rule" "cluster_private_access_sg_source" {
  count = var.cluster_create_endpoint_private_access_sg_rule && var.cluster_endpoint_private_access && var.cluster_endpoint_private_access_sg != null ? length(var.cluster_endpoint_private_access_sg) : 0

  description = "Allow private K8S API ingress from custom Security Groups source."

  security_group_id        = local.cluster_security_group_id
  source_security_group_id = var.cluster_endpoint_private_access_sg[count.index]

  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  type      = "ingress"
}

resource "aws_security_group" "workers" {
  name_prefix = local.cluster_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = module.vpc.vpc_id

  # One, and only one, of the security groups associated to
  # your nodes should have the following tag applied.
  tags = merge(
    var.tags,
    {
      "Name"                                        = "${local.cluster_name}-eks_worker_sg"
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
    },
  )
}
resource "aws_security_group_rule" "workers_egress_internet" {
  description = "Allow nodes all egress to the Internet."

  security_group_id = local.worker_security_group_id
  cidr_blocks       = var.workers_egress_cidrs

  from_port = 0
  to_port   = 0
  protocol  = "-1"
  type      = "egress"
}
# Nodes require access to the Amazon EKS APIs for cluster
# introspection and node registration at launch time either
# through the internet or VPC endpoints.
resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description = "Allow pods to communicate with the EKS cluster API."

  security_group_id        = local.cluster_security_group_id
  source_security_group_id = local.worker_security_group_id

  from_port = 443
  to_port   = 443
  protocol  = "tcp"
  type      = "ingress"
}
