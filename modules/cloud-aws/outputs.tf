# output "cluster_id" {
#   description = "The ID of the EKS cluster."
#   value       = local.cluster_id
#   depends_on  = [data.http.wait_for_cluster]
# }

# output "cluster_arn" {
#   description = "The Amazon Resource Name (ARN) of the cluster."
#   value       = local.cluster_arn
# }

# output "cluster_version" {
#   description = "The Kubernetes server version for the EKS cluster."
#   value       = element(concat(aws_eks_cluster.main[*].version, [""]), 0)
# }

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = local.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = local.cluster_iam_role_arn
}

# output "worker_iam_instance_profile_arns" {
#   description = "Default IAM instance profile ARN for EKS worker groups"
#   value = concat(
#     aws_iam_instance_profile.workers.*.arn,
#     aws_iam_instance_profile.workers_launch_template.*.arn
#   )
# }

# output "worker_iam_instance_profile_names" {
#   description = "Default IAM instance profile name for EKS worker groups"
#   value = concat(
#     aws_iam_instance_profile.workers.*.name,
#     aws_iam_instance_profile.workers_launch_template.*.name
#   )
# }

# output "worker_iam_role_name" {
#   description = "Default IAM role name for EKS worker groups"
#   value = coalescelist(
#     aws_iam_role.workers.*.name,
#     data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.role_name,
#     data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile.*.role_name,
#     [""]
#   )[0]
# }

# output "worker_iam_role_arn" {
#   description = "Default IAM role ARN for EKS worker groups"
#   value = coalescelist(
#     aws_iam_role.workers.*.arn,
#     data.aws_iam_instance_profile.custom_worker_group_iam_instance_profile.*.role_arn,
#     data.aws_iam_instance_profile.custom_worker_group_launch_template_iam_instance_profile.*.role_arn,
#     [""]
#   )[0]
# }

# output "kubeconfig" {
#   description = "kubectl config file contents for this EKS cluster."
#   value       = local.kubeconfig

#   # So that calling plans wait for the cluster to be available before attempting to use it.
#   # There is no need to duplicate this datasource
#   depends_on = [data.http.wait_for_cluster]
# }
