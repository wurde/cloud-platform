# AWS Identity and Access Management (IAM)
# https://aws.amazon.com/iam

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "cluster" {
  # Friendly name of the role.
  name = local.cluster_iam_role_name

  # (Required) Policy that grants an entity permission to assume the role.
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json

  # Whether to force detaching any policies the role has before destroying it.
  force_detach_policies = true

  # Key-value mapping of tags for the IAM role.
  tags = var.tags
}
# Generates an IAM policy document in JSON format.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "cluster_elb_sl_role_creation" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeAddresses"
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "cluster_elb_sl_role_creation" {
  name_prefix = "${local.cluster_name}-elb-sl-role-creation"
  description = "Permissions for EKS to create AWSServiceRoleForElasticLoadBalancing service-linked role"
  policy      = data.aws_iam_policy_document.cluster_elb_sl_role_creation.json

  tags = var.tags
}
resource "aws_iam_role_policy_attachment" "cluster_elb_sl_role_creation" {
  policy_arn = aws_iam_policy.cluster_elb_sl_role_creation.arn
  role       = local.cluster_iam_role_name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "workers" {
  # Friendly name of the role.
  name = local.workers_iam_role_name

  # (Required) Policy that grants an entity permission to assume the role.
  assume_role_policy = data.aws_iam_policy_document.workers_assume_role_policy.json

  # Whether to force detaching any policies the role has before destroying it.
  force_detach_policies = true

  # Key-value mapping of tags for the IAM role.
  tags = var.tags
}
# Generates an IAM policy document in JSON format.
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = [local.ec2_principal]
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "workers" {
  role = local.default_iam_role_id
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "workers_launch_template" {
  role = local.default_iam_role_id
  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = local.workers_iam_role_name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = local.workers_iam_role_name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = local.workers_iam_role_name
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
  count = length(var.workers_additional_policies)

  role       = local.workers_iam_role_name
  policy_arn = var.workers_additional_policies[count.index]
}
