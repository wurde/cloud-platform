# Cloud Platform

A Kubernetes environment.

## Prerequisites

- A cloud account with either AWS or GCP.

## Usage example

```hcl
module "cloud-platform" {
  source = "https://github.com/wurde/cloud-platform"

  cloud = "aws"
}
```

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cloud"></a> [aws-cloud](./modules/aws-cloud/README.md) | ./modules/aws-cloud |  |
| <a name="module_gcp_cloud"></a> [gcp-cloud](./modules/gcp-cloud/README.md) | ./modules/gcp-cloud |  |

## License

This project is __FREE__ to use, reuse, remix, and resell.
This is made possible by the [MIT license](/LICENSE).
