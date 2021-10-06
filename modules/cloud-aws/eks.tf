# Amazon Elastic Kubernetes Service (EKS)
# https://aws.amazon.com/eks

# A managed service that you can use to run Kubernetes on AWS
# The control plane consists of at least two API server
# instances and three etcd instances that run across three
# Availability Zones within a Region.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
resource "aws_eks_cluster" "main" {
  name                      = local.cluster_name
  enabled_cluster_log_types = var.cluster_enabled_log_types
  role_arn                  = local.cluster_iam_role_arn
  version                   = var.cluster_version

  # Configuration block for the VPC associated with your cluster.
  # Amazon EKS VPC resources have specific requirements to work
  # properly with Kubernetes.
  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  # https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
  vpc_config {
    security_group_ids  = compact([local.cluster_security_group_id])

    # List of subnet IDs. Must be in at least two different
    # availability zones. Amazon EKS creates cross-account
    # elastic network interfaces in these subnets to allow
    # communication between your worker nodes and the
    # Kubernetes control plane.
    subnet_ids              = module.vpc.private_subnets
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_endpoint_public_access_cidrs
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.cluster_service_ipv4_cidr
  }

  dynamic "encryption_config" {
    for_each = toset(var.cluster_encryption_config)

    content {
      provider {
        key_arn = encryption_config.value["provider_key_arn"]
      }
      resources = encryption_config.value["resources"]
    }
  }

  tags = merge(
    var.tags,
    {},
  )

  timeouts {
    create = "30m"
    delete = "15m"
    update = "60m"
  }

  depends_on = [
    aws_security_group_rule.cluster_egress_internet,
    aws_security_group_rule.cluster_https_worker_ingress,
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceControllerPolicy,
    aws_cloudwatch_log_group.main
  ]
}

# With Amazon EKS managed node groups, you don’t need
# to separately provision or register the Amazon EC2
# instances that provide compute capacity to run your
# Kubernetes applications. All managed nodes are
# provisioned as part of an Amazon EC2 Auto Scaling
# group that's managed for you by Amazon EKS. You can
# create, automatically update, or terminate nodes for
# your cluster with a single operation. Nodes run using
# the latest Amazon EKS optimized AMIs in your AWS
# account. Node updates and terminations automatically
# and gracefully drain nodes to ensure that your
# applications stay available.
#
# By default, instances in a managed node group use the
# latest version of the EKS optimized Amazon Linux 2 AMI.
#
# You can create multiple managed node groups within a
# single cluster. For example creating node groups for
# GPU or Spot workloads.
#
# https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main"
  node_role_arn   = aws_iam_role.main.arn # TODO reference
  subnet_ids      = aws_subnet.main[*].id # TODO reference

  # TODO variables
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  # TODO variables
  update_config {
    max_unavailable = 2
  }

  # TODO other config? Worker group defaults (locals)?

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly,
  ]
}
