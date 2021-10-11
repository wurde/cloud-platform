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

  # Merge defaults and per-group values
  # https://www.terraform.io/docs/language/expressions/for.html
  # https://www.terraform.io/docs/language/functions/merge.html
  node_groups_expanded = { for k, v in var.node_groups : k => merge(
    {
      capacity_type           = "ON_DEMAND"
      ami_type                = "AL2_x86_64"
      instance_types          = ["t3.medium"]
      desired_capacity        = "1"
      max_capacity            = "3"
      min_capacity            = "1"
      disk_size               = "20"
      disk_type               = "gp2"
      create_launch_template  = false
    },
    var.node_groups_defaults,
    v,
  )}

  # During bootstrapping the EKS cluster uses the Node Authorization
  # mode to allow nodes to register themselves.  It requires that
  # each node belongs to the group `system:nodes` with a  username
  # of `system:node:<nodeName>`.
  configmap_node_group_role = [{
    # IAM role associated with your nodes. Format of the role ARN
    # must be arn:aws:iam::<123456789012>:role/<role-name>
    rolearn = aws_iam_role.workers.arn
    # The username within Kubernetes to map to the IAM role.
    username = "system:node:{{EC2PrivateDNSName}}"
    # A list of groups within Kubernetes to which the role is mapped.
    groups = tolist(concat([
      "system:bootstrappers",
      "system:nodes",
    ]))
  }]

  configmap_root_user = [{
    userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
    username = "cluster-admin"
    groups   = ["system:masters"]
  }]

  configmap_kubernetes_admin_user = [{
    userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/KubernetesAdmin"
    username = "kubernetes-admin"
    groups   = ["system:masters"]
  }]

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
