# https://registry.terraform.io/providers/hashicorp/local

# resource "local_file" "kubeconfig" {
#   count = var.write_kubeconfig ? 1 : 0

#   content              = local.kubeconfig
#   filename             = substr(var.kubeconfig_output_path, -1, 1) == "/" ? "${var.kubeconfig_output_path}kubeconfig_${var.cluster_name}" : var.kubeconfig_output_path
#   file_permission      = "0600"
#   directory_permission = "0755"
# }
