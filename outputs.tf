output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.cloud_aws.cluster_id
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.cloud_aws.cluster_arn
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_endpoint" {
  description = "Endpoint of the cluster."
  value       = module.cloud_aws.cluster_endpoint
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.cloud_aws.cluster_version
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = module.cloud_aws.cluster_auth_base64
  # TODO
  #depends_on  = [data.http.wait_for_cluster]
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster."
  value       = module.cloud_aws.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN of the EKS cluster."
  value       = module.cloud_aws.cluster_iam_role_arn
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = module.cloud_aws.kubeconfig

  # So that calling plans wait for the cluster to be available before attempting to use it.
  # There is no need to duplicate this datasource
  # TODO
  #depends_on = [data.http.wait_for_cluster]
}
