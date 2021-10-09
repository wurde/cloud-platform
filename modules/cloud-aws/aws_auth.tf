# Kubernetes ConfigMap
#
# The resource provides mechanisms to inject containers
# with configuration data while keeping containers
# agnostic of Kubernetes. Config Map can be used to
# store fine-grained information like individual
# properties or coarse-grained information like entire
# config files or JSON blobs.

# To grant additional AWS users or roles the ability
# to interact with your cluster, you must edit the
# aws-auth ConfigMap within Kubernetes.
#
# It is initially created to allow your nodes to
# join your cluster, but you also use this ConfigMap
# to add RBAC access to IAM users and roles.
#
# https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html
# https://github.com/kubernetes-sigs/aws-iam-authenticator/blob/master/README.md
# https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
    labels    = {
      "app.kubernetes.io/managed-by" = "Terraform"
    }
  }

  data = {
    # IAM Roles
    mapRoles = yamlencode(
      distinct(concat(
        # Add the node instance role so that nodes can
        # register themselves with the cluster.
        local.configmap_node_group_role,
        var.map_iam_roles,
      ))
    )
    # IAM Users
    mapUsers = yamlencode(var.map_iam_users)
    # Map IAM users from these AWS Accounts
    # to `username` in the EKS cluster. If
    # the users have the correct IAM
    # permissions to connect then they
    # should be able to authenticate.
    mapAccounts = yamlencode(concat(
      # AWS Account ID where this config is deployed.
      [data.aws_caller_identity.current.account_id],
      var.map_aws_accounts,
    ))
  }

  depends_on = [local.kubeconfig]
}
