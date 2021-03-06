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
  role_arn                  = join("", aws_iam_role.cluster.*.arn)
  version                   = var.cluster_version

  # Configuration block for the VPC associated with your cluster.
  # Amazon EKS VPC resources have specific requirements to work
  # properly with Kubernetes.
  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
  # https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
  vpc_config {
    security_group_ids = [aws_security_group.cluster.id]

    # List of subnet IDs. Must be in at least two different
    # availability zones. Amazon EKS creates cross-account
    # elastic network interfaces in these subnets to allow
    # communication between your worker nodes and the
    # Kubernetes control plane.
    subnet_ids = module.vpc.public_subnets

    # Indicates whether or not the Amazon EKS public API
    # server endpoint is enabled.
    endpoint_public_access = true
    # List of CIDR blocks which can access the Amazon EKS
    # public API server endpoint.
    public_access_cidrs = ["0.0.0.0/0"]

    endpoint_private_access = false
  }

  kubernetes_network_config {
    service_ipv4_cidr = null
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

# With Amazon EKS managed node groups, you don???t need
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
# Spot Instances can be interrupted with a two-minute
# interruption notice when EC2 needs the capacity back.
# So only fault-tolerant apps should be deployed there.
# Use this `label` to schedule apps on SPOT instances:
#
#   eks.amazonaws.com/capacityType: SPOT
#
# The allocation strategy to provision Spot capacity
# is set to capacity-optimized to ensure that your Spot
# nodes are provisioned in the optimal Spot capacity
# pools. To increase the number of Spot capacity pools
# available for allocating capacity from, we recommend
# that you configure a managed node group to use
# multiple instance types. Instance types should have
# the same amount of vCPU and memory resources to
# ensure that the nodes in your cluster scale as
# expected. For example, if you need four vCPUs and
# eight GiB memory, we recommend that you use
# c3.xlarge, c4.xlarge, c5.xlarge, c5d.xlarge,
# c5a.xlarge, c5n.xlarge, or other similar instance
# types.
#
# Use On-Demand Instances for fault intolerant apps.
# This includes cluster management tools such as
# monitoring and operational tools, deployments that
# require StatefulSets, and stateful applications,
# such as databases. Use this `label` to schedule apps
# on On-Demand instances:
#
#   eks.amazonaws.com/capacityType: ON_DEMAND
#
# https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_eks_node_group" "workers" {
  for_each = local.node_groups_expanded

  # Name of the EKS Node Group.
  # Example: node_group_name = "main"
  node_group_name = lookup(each.value, "name", null)

  # Name of the EKS Cluster.
  cluster_name = aws_eks_cluster.main.name

  # IAM Role that provides permissions for the EKS Node Group.
  node_role_arn = aws_iam_role.workers.arn

  # Identifiers of EC2 Subnets to associate with.
  subnet_ids = module.vpc.public_subnets

  # Type of capacity associated with the EKS Node Group.
  # Valid values: ON_DEMAND, SPOT
  # Example: capacity_type = "ON_DEMAND"
  capacity_type = lookup(each.value, "capacity_type", "ON_DEMAND")

  # Type of AMI associated with the EKS Node Group.
  # Defaults to AL2_x86_64. Valid values: AL2_x86_64,
  # AL2_x86_64_GPU, AL2_ARM_64, or CUSTOM.
  # Example: ami_type = "AL2_x86_64"
  ami_type = lookup(each.value, "ami_type", "AL2_x86_64")

  # Set of instance types associated with the EKS
  # Node Group. Defaults to ["t3.medium"]
  # Example: instance_types = ["t3.medium"]
  instance_types = each.value["instance_types"]

  scaling_config {
    desired_size = each.value["desired_capacity"]
    max_size     = each.value["max_capacity"]
    min_size     = each.value["min_capacity"]
  }

  # Disk size in GiB for worker nodes. Defaults to 20.
  # Example: disk_size = 100
  disk_size = lookup(each.value, "disk_size", 20)

  # Desired max percentage of unavailable worker nodes
  # during node group update.
  update_config {
    max_unavailable_percentage = lookup(each.value, "max_unavailable_percentage", 25)
  }

  labels = merge(
    lookup(var.node_groups_defaults, "k8s_labels", {}),
    lookup(var.node_groups[each.key], "k8s_labels", {})
  )

  tags = merge(
    var.tags,
    lookup(var.node_groups_defaults, "additional_tags", {}),
    lookup(var.node_groups[each.key], "additional_tags", {}),
  )

  # Allow external changes without Terraform plan difference
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    kubernetes_config_map.aws_auth,
    aws_iam_role_policy_attachment.workers_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.workers_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.workers_AmazonEC2ContainerRegistryReadOnly,
  ]
}
