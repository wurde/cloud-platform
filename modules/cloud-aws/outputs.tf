output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = local.cluster_id
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = local.cluster_arn
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_endpoint" {
  description = "Endpoint of the cluster."
  value       = local.cluster_endpoint
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = element(concat(aws_eks_cluster.main[*].version, [""]), 0)
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = local.cluster_auth_base64
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = local.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = local.cluster_iam_role_arn
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = local.kubeconfig

  # So that calling plans wait for the cluster to be available before attempting to use it.
  # There is no need to duplicate this datasource
  # TODO
  #depends_on = [data.http.wait_for_cluster]
}
