# https://www.terraform.io/docs/language/settings/index.html
# Configure some behaviors of Terraform itself.
terraform {
  # Specify which versions of Terraform can be used with this configuration.
  required_version = "~> v1.1"

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
