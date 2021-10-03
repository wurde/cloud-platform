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

  # Specify all of the required providers.
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
  }
}
```

Local terraform configuration:

```hcl
module "cloud-platform" {
  source = "git::github.com/wurde/cloud-platform"

  cloud = "aws"
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cloud"></a> [aws-cloud](./modules/aws-cloud/README.md) | ./modules/aws-cloud |  |
| <a name="module_gcp_cloud"></a> [gcp-cloud](./modules/gcp-cloud/README.md) | ./modules/gcp-cloud |  |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud"></a> [cloud](#input_cloud) | What cloud do you want to deploy to? AWS or GCP? | `string` | `aws` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster_id](#output_cluster_id) | The ID of the EKS cluster. Will block on cluster creation until the cluster is really ready. |
| <a name="output_cluster_version"></a> [cluster_version](#output_cluster_version) | The Kubernetes server version for the EKS cluster. |

## License

This project is __FREE__ to use, reuse, remix, and resell.
This is made possible by the [MIT license](/LICENSE).
