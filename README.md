# Cloud Platform

A Kubernetes environment.

## Prerequisites

- A cloud account with either AWS or GCP.

## Usage example

Create an AWS account and set the following environment variables.

```bash
export AWS_ACCESS_KEY_ID=QEIACXB1X3R78R12U73G
export AWS_SECRET_ACCESS_KEY=rUo81hDSgLuGMJ3zhA041v/GC/0ZHjOYy/Jma8Gh
```

Setup the Terraform configuration.

```hcl
# https://www.terraform.io/docs/language/settings/index.html
# Configure some behaviors of Terraform itself.
terraform {
  # Specify which versions of Terraform can be used with this configuration.
  required_version = "~> v1.1"

  # Stores the state as a key in a bucket on Amazon S3.
  # https://www.terraform.io/docs/backends/types/s3.html
  backend "s3" {
    bucket = "my-terraform-backend"
    key    = "cloud-platform/k8s.example.com/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.61"
    }

    # https://registry.terraform.io/providers/hashicorp/google
    google = {
      source  = "hashicorp/google"
      version = "~> 3.86"
    }

    # https://registry.terraform.io/providers/hashicorp/http
    http = {
      source  = "hashicorp/http"
      version = "~> 2.1"
    }

    # https://registry.terraform.io/providers/hashicorp/local
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1"
    }

    # https://registry.terraform.io/providers/hashicorp/random
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
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      additional_userdata  = "echo foo bar"
      asg_desired_capacity = 2
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t2.medium"
      additional_userdata  = "echo foo bar"
      asg_desired_capacity = 1
    },
  ]

  cluster_enabled_log_types = ["api", "audit"]

  tags {
    Environment = "production"
  }
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloud_aws"></a> [cloud-aws](./modules/cloud-aws/README.md) | ./modules/cloud-aws |  |
| <a name="module_cloud_gcp"></a> [cloud-gcp](./modules/cloud-gcp/README.md) | ./modules/cloud-gcp |  |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud"></a> [cloud](#input_cloud) | What cloud do you want to deploy to? AWS or GCP? | `string` | `aws` | no |
| <a name="input_region"></a> [region](#input_region) | What region do you want to deploy to? | `string` | `us-east-2` | no |
| <a name="input_cluster_version"></a> [cluster_version](#input_cluster_version) | Kubernetes version to use for the EKS cluster. | `string` | `1.21` | no |
| <a name="input_wait_for_cluster_timeout"></a> [wait_for_cluster_timeout](#input_wait_for_cluster_timeout) | A timeout (in seconds) to wait for cluster to be available. | `number` | `300` | no |
| <a name="input_cluster_log_retention_in_days"></a> [cluster_log_retention_in_days](#input_cluster_log_retention_in_days) | Number of days to retain log events. Default retention - 90 days. | `number` | `90` | no |
| <a name="input_write_kubeconfig"></a> [write_kubeconfig](#input_write_kubeconfig) | Whether to write a Kubectl config file containing the cluster configuration. Saved to kubeconfig_output_path. | `bool` | `true` | no |
| <a name="input_kubeconfig_output_path"></a> [kubeconfig_output_path](#input_kubeconfig_output_path) | Where to save the Kubectl config file (if write_kubeconfig = true). | `string` | `./` | no |
| <a name="input_kubeconfig_file_permission"></a> [kubeconfig_file_permission](#input_kubeconfig_file_permission) | File permission of the Kubectl config file containing cluster configuration saved to `kubeconfig_output_path. | `string` | `0600` | no |
| <a name="input_kubeconfig_aws_authenticator_command"></a> [kubeconfig_aws_authenticator_command](#input_kubeconfig_aws_authenticator_command) | Command to use to fetch AWS EKS credentials. | `string` | `aws-iam-authenticator` | no |
| <a name="input_kubeconfig_aws_authenticator_command_args"></a> [kubeconfig_aws_authenticator_command_args](#input_kubeconfig_aws_authenticator_command_args) | Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]. | `list(string)` | `[]` | no |
| <a name="input_kubeconfig_aws_authenticator_additional_args"></a> [kubeconfig_aws_authenticator_additional_args](#input_kubeconfig_aws_authenticator_additional_args) | Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]. | `list(string)` | `[]` | no |
| <a name="input_kubeconfig_aws_authenticator_env_variables"></a> [kubeconfig_aws_authenticator_env_variables](#input_kubeconfig_aws_authenticator_env_variables) | Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input_tags) | A map of tags to add to all resources. | `map(string)` | `{}` | no |
| <a name="input_cluster_tags"></a> [cluster_tags](#input_cluster_tags) | A map of tags to add to just the eks resource. | `map(string)` | `{}` | no |
| <a name="input_cluster_create_timeout"></a> [cluster_create_timeout](#input_cluster_create_timeout) | Timeout value when creating the EKS cluster. | `string` | `30m` | no |
| <a name="input_cluster_delete_timeout"></a> [cluster_delete_timeout](#input_cluster_delete_timeout) | Timeout value when deleting the EKS cluster. | `string` | `15m` | no |
| <a name="input_cluster_update_timeout"></a> [cluster_update_timeout](#input_cluster_update_timeout) | Timeout value when updating the EKS cluster. | `string` | `60m` | no |
| <a name="input_worker_groups"></a> [worker_groups](#input_worker_groups) | A list of maps defining worker group configurations to be defined using AWS Launch Configurations. | `list(any)` | `[]` | no |
| <a name="input_workers_group_defaults"></a> [workers_group_defaults](#input_workers_group_defaults) | Override default values for target groups. | `any` | `[]` | no |
| <a name="input_worker_groups_launch_template"></a> [worker_groups_launch_template](#input_worker_groups_launch_template) | A list of maps defining worker group configurations to be defined using AWS Launch Templates. | `any` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster_id](#output_cluster_id) | The ID of the EKS cluster. |
| <a name="output_cluster_arn"></a> [cluster_arn](#output_cluster_arn) | The Amazon Resource Name (ARN) of the cluster. |
| <a name="output_cluster_version"></a> [cluster_version](#output_cluster_version) | The Kubernetes server version for the EKS cluster. |
| <a name="output_cluster_iam_role_name"></a> [cluster_iam_role_name](#output_cluster_iam_role_name) | IAM role name of the EKS cluster. |
| <a name="output_cluster_iam_role_arn"></a> [cluster_iam_role_arn](#output_cluster_iam_role_arn) | IAM role ARN of the EKS cluster. |
| <a name="output_worker_iam_instance_profile_arns"></a> [worker_iam_instance_profile_arns](#output_worker_iam_instance_profile_arns) | Default IAM instance profile ARN for EKS worker groups. |
| <a name="output_worker_iam_instance_profile_names"></a> [worker_iam_instance_profile_names](#output_worker_iam_instance_profile_names) | Default IAM instance profile name for EKS worker groups. |
| <a name="output_worker_iam_role_name"></a> [worker_iam_role_name](#output_worker_iam_role_name) | Default IAM role name for EKS worker groups. |
| <a name="output_worker_iam_role_arn"></a> [worker_iam_role_arn](#output_worker_iam_role_arn) | Default IAM role ARN for EKS worker groups. |
| <a name="output_kubeconfig"></a> [kubeconfig](#output_kubeconfig) | kubectl config file contents for this EKS cluster. |

## License

This project is __FREE__ to use, reuse, remix, and resell.
This is made possible by the [MIT license](/LICENSE).
