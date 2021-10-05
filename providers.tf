# AWS provider
# https://registry.terraform.io/providers/hashicorp/aws
provider "aws" {
  region = var.region
}

# Kubernetes provider
# https://registry.terraform.io/providers/hashicorp/kubernetes
# The Kubernetes provider is included only to ensure that EKS
# is provisioned successfully. Otherwise, it throws an error when
# creating `kubernetes_config_map.aws_auth`. Do not schedule
# deployments and services in this workspace.
# provider "kubernetes" {
#   host                   = module.cloud_aws.cluster_endpoint
#   token                  = module.cloud_aws.aws_eks_cluster_auth.cluster.token
#   cluster_ca_certificate = base64decode(module.cloud_aws.cluster_certificate_authority_data)
# }
