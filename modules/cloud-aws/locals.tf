locals {
  cluster_name = "eks-cluster-${random_string.suffix.result}"

  # cluster_id          = coalescelist(module.cloud_aws.aws_eks_cluster.this[*].id, [""])[0]
  # cluster_auth_base64 = coalescelist(module.cloud_aws.aws_eks_cluster.this[*].certificate_authority[0].data, [""])[0]
  # cluster_endpoint    = coalescelist(module.cloud_aws.aws_eks_cluster.this[*].endpoint, [""])[0]

  workers_iam_role_name = "iam-eks-workers-${random_string.suffix.result}"
  cluster_iam_role_name = "iam-eks-cluster-${random_string.suffix.result}"
  cluster_iam_role_arn  = join("", aws_iam_role.cluster.*.arn)

  ec2_principal = "ec2.${data.aws_partition.current.dns_suffix}"

  # kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", {
  #   kubeconfig_name                   = "eks_${var.cluster_name}"
  #   endpoint                          = local.cluster_endpoint
  #   cluster_auth_base64               = local.cluster_auth_base64
  #   aws_authenticator_command         = var.kubeconfig_aws_authenticator_command
  #   aws_authenticator_command_args    = coalescelist(var.kubeconfig_aws_authenticator_command_args, ["token", "-i", local.cluster_name])
  #   aws_authenticator_additional_args = var.kubeconfig_aws_authenticator_additional_args
  #   aws_authenticator_env_variables   = var.kubeconfig_aws_authenticator_env_variables
  # })
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
