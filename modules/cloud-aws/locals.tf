locals {
  cluster_name = "eks-cluster-${random_string.suffix.result}"

  cluster_id          = coalescelist(aws_eks_cluster.main[*].id, [""])[0]
  cluster_arn         = coalescelist(aws_eks_cluster.main[*].arn, [""])[0]
  cluster_auth_base64 = coalescelist(aws_eks_cluster.main[*].certificate_authority[0].data, [""])[0]
  cluster_endpoint    = coalescelist(aws_eks_cluster.main[*].endpoint, [""])[0]

  vpc_name = "vpc-eks-${random_string.suffix.result}"
  vpc_cidr = "10.0.0.0/16"

  # The Amazon EKS optimized Amazon Linux AMI is built on top of Amazon Linux 2,
  # and is configured to serve as the base image for Amazon EKS nodes. It includes
  # Docker, kubelet, and the AWS IAM Authenticator.
  # https://docs.aws.amazon.com/eks/latest/userguide/eks-optimized-ami.html
  worker_ami_name_filter = "amazon-eks-node-${coalesce(var.cluster_version, "cluster_version")}-v*"

  ec2_principal     = "ec2.${data.aws_partition.current.dns_suffix}"
  eks_principal     = "eks.${data.aws_partition.current.dns_suffix}"
  policy_arn_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  # Convert to format needed by aws-auth ConfigMap
  configmap_node_group_role = [
    {
      # The ARN of the IAM role to add.
      #   Work around https://github.com/kubernetes-sigs/aws-iam-authenticator/issues/153
      #   Strip the leading slash off so that Terraform doesn't think it's a regex
      rolearn  = replace(aws_iam_role.workers.arn, replace(var.iam_path, "/^//", ""), "")
      # The user name within Kubernetes to map to the IAM role.
      username = "system:node:{{EC2PrivateDNSName}}"
      # A list of groups within Kubernetes to which the role is mapped.
      groups = tolist(concat([
        "system:bootstrappers",
        "system:nodes",
      ]))
    }
  ]

  kubeconfig = templatefile("${path.module}/../../templates/kubeconfig.tpl", {
    kubeconfig_name                   = "eks_${local.cluster_name}"
    endpoint                          = local.cluster_endpoint
    cluster_auth_base64               = local.cluster_auth_base64
    aws_authenticator_command         = "aws-iam-authenticator"
    aws_authenticator_command_args    = ["token", "-i", local.cluster_name]
    aws_authenticator_additional_args = []
    aws_authenticator_env_variables   = {}
  })
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}
