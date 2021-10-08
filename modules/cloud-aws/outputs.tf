output "cluster_name" {
  description = "The name of the EKS cluster."
  value       = local.cluster_name
}

output "cluster_id" {
  description = "The ID of the EKS cluster."
  value       = local.cluster_id
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster."
  value       = local.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint of the cluster."
  value       = local.cluster_endpoint
}

output "cluster_version" {
  description = "The Kubernetes server version for the EKS cluster."
  value       = element(concat(aws_eks_cluster.main[*].version, [""]), 0)
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with your cluster."
  value       = local.cluster_auth_base64
}

output "kubeconfig" {
  description = "kubectl config file contents for this EKS cluster."
  value       = local.kubeconfig
}
