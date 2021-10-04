# AWS Identity and Access Management (IAM)
# https://aws.amazon.com/iam

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
# TODO aws_iam_policy_document
resource "aws_iam_role" "cluster" {
  # Friendly name of the role.
  name = locals.cluster_iam_role_name

  # (Required) Policy that grants an entity permission to assume the role.
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role_policy.json

  # Whether to force detaching any policies the role has before destroying it.
  force_detach_policies = true

  # Key-value mapping of tags for the IAM role.
  tags = var.tags
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "workers" {
  # Friendly name of the role.
  name = locals.workers_iam_role_name

  # (Required) Policy that grants an entity permission to assume the role.
  assume_role_policy = data.aws_iam_policy_document.workers_assume_role_policy.json

  # Whether to force detaching any policies the role has before destroying it.
  force_detach_policies = true

  # Key-value mapping of tags for the IAM role.
  tags = var.tags
}

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
# resource "aws_iam_instance_profile" "workers" {
#   count = local.worker_group_launch_configuration_count

#   name_prefix = local.cluster_name
#   role = lookup(
#     var.worker_groups[count.index],
#     "iam_role_id",
#     local.default_iam_role_id,
#   )

#   tags = var.tags

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
# resource "aws_iam_instance_profile" "workers_launch_template" {
#   count = local.worker_group_launch_template_count

#   name_prefix = local.cluster_name
#   role = lookup(
#     var.worker_groups_launch_template[count.index],
#     "iam_role_id",
#     local.default_iam_role_id,
#   )

#   tags = var.tags

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_iam_role_policy_attachment" "workers_AmazonEKSWorkerNodePolicy" {
#   policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.workers[0].name
# }

# resource "aws_iam_role_policy_attachment" "workers_AmazonEKS_CNI_Policy" {
#   count = var.attach_worker_cni_policy ? 1 : 0

#   policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.workers[0].name
# }

# resource "aws_iam_role_policy_attachment" "workers_AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.workers[0].name
# }

# resource "aws_iam_role_policy_attachment" "workers_additional_policies" {
#   count = length(var.workers_additional_policies)

#   role       = aws_iam_role.workers[0].name
#   policy_arn = var.workers_additional_policies[count.index]
# }

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
