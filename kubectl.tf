# https://registry.terraform.io/providers/hashicorp/local

# https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig
resource "local_file" "kubeconfig" {
  content              = local.kubeconfig
  filename             = "~/.kube/kubeconfig_${var.cluster_name}"
  file_permission      = "0600"
  directory_permission = "0755"
}
