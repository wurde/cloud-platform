# Cloud Platform

A Kubernetes environment.

## Prerequisites

- A cloud account with AWS.

## Usage example

Create an AWS account and set the following environment variables.

```bash
export AWS_ACCESS_KEY_ID=QEIACXB1X3R78R12U73G
export AWS_SECRET_ACCESS_KEY=rUo81hDSgLuGMJ3zhA041v/GC/0ZHjOYy/Jma8Gh
```

Setup the Terraform configuration.

```hcl
terraform {
  required_version = "~> v1.1"

  backend "s3" {
    bucket = "my-terraform-backend"
    key    = "cloud-platform/k8s.example.com/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.61"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}
```

Local terraform configuration:

```hcl
module "cloud-platform" {
  source = "git::github.com/wurde/cloud-platform"

  cloud  = "aws"
  region = "us-east-2"

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name             = "worker-group-1"
      capacity_type    = "ON_DEMAND"
      instance_types   = ["t2.small"]
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1
    },
    {
      name             = "worker-group-2"
      capacity_type    = "SPOT"
      instance_types   = ["t2.medium"]
      desired_capacity = 1
      max_capacity     = 10
      min_capacity     = 1
    },
  ]

  cluster_enabled_log_types = ["api", "audit"]

  tags {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input_region) | What region do you want to deploy to? | `string` | `us-east-2` | no |
| <a name="input_cluster_version"></a> [cluster_version](#input_cluster_version) | Kubernetes version to use for the EKS cluster. | `string` | `1.21` | no |
| <a name="input_cluster_enabled_log_types"></a> [cluster_enabled_log_types](#input_cluster_enabled_log_types) | A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html) | `list(string)` | `[]` | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster_log_retention_in_days](#input_cluster_log_retention_in_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_kubeconfig_output_path"></a> [kubeconfig_output_path](#input_kubeconfig_output_path) | Where to save the Kubectl config file (if write_kubeconfig = true). | `string` | `./` | no |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_worker_groups"></a> [worker_groups](#input_worker_groups) | A list of maps defining worker group configurations to be defined using AWS Launch Configurations. | `list(any)` | `[]` | no |
| <a name="input_workers_group_defaults"></a> [workers_group_defaults](#input_workers_group_defaults) | Override default values for target groups. | `any` | `[]` | no |
| <a name="input_worker_groups_launch_template"></a> [worker_groups_launch_template](#input_worker_groups_launch_template) | A list of maps defining worker group configurations to be defined using AWS Launch Templates. | `any` | `[]` | no |
| <a name="input_map_iam_roles"></a> [map_iam_roles](#input_map_iam_roles) | Additional IAM roles to add to the aws-auth configmap. | `list(object({ rolearn = string, username = string, groups = list(string) }))` | `[]` | no |
| <a name="input_map_iam_users"></a> [map_iam_users](#input_map_iam_users) | Additional IAM users to add to the aws-auth configmap. | `list(object({ userarn = string, username = string, groups = list(string) }))` | `[]` | no |
| <a name="input_map_aws_accounts"></a> [map_aws_accounts](#input_map_aws_accounts) | Additional AWS account numbers to add to the aws-auth configmap. | `list(object({ userarn = string, username = string, groups = list(string) }))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster_name](#output_cluster_name) | The name of the EKS cluster. |
| <a name="output_cluster_id"></a> [cluster_id](#output_cluster_id) | The ID of the EKS cluster. |
| <a name="output_cluster_arn"></a> [cluster_arn](#output_cluster_arn) | The Amazon Resource Name (ARN) of the cluster. |
| <a name="output_cluster_version"></a> [cluster_version](#output_cluster_version) | The Kubernetes server version for the EKS cluster. |
| <a name="output_cluster_endpoint"></a> [cluster_endpoint](#output_cluster_endpoint) | Endpoint of the cluster. |
| <a name="output_cluster_certificate_authority_data"></a> [cluster_certificate_authority_data](#output_cluster_certificate_authority_data) | Base64 encoded certificate data required to communicate with your cluster. |
| <a name="output_kubeconfig"></a> [kubeconfig](#output_kubeconfig) | kubectl config file contents for this EKS cluster. |

## License

This project is __FREE__ to use, reuse, remix, and resell.
This is made possible by the [MIT license](/LICENSE).
