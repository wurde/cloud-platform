# AWS provider
# https://registry.terraform.io/providers/hashicorp/aws
provider "aws" {
  region = var.region
}

# Kubernetes provider
# https://registry.terraform.io/providers/hashicorp/kubernetes
provider "kubernetes" {
  host                   = module.cloud_aws.0.cluster_endpoint
  cluster_ca_certificate = base64decode(module.cloud_aws.0.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", module.cloud_aws.0.cluster_name]
    command     = "aws"
  }
}
