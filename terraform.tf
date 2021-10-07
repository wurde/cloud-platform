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

    # https://registry.terraform.io/providers/hashicorp/http
    http = {
      source  = "hashicorp/http"
      version = "~> 2.4"
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
