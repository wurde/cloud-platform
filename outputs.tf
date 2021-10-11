output "region" {
  description = "AWS or GCP region."
  value       = var.region
}

output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.cloud_aws.0.cluster_name
}

output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = module.cloud_aws.0.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = module.cloud_aws.0.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint of the cluster."
  value       = module.cloud_aws.0.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = module.cloud_aws.0.cluster_version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = module.cloud_aws.0.cluster_certificate_authority_data
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = module.cloud_aws.0.kubeconfig
}
