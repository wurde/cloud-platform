variable "cloud" {
  default     = "aws"
  type        = string
  description = "What cloud do you want to deploy to? [aws (default), gcp]"

  validation {
    condition = var.cloud == "aws" || var.cloud == "gcp"
    error_message = "The cloud must be either 'aws' or 'gcp'."
  }
}

variable "region" {
  default     = "us-west-2"
  type        = string
  description = "AWS or GCP region. Default is AWS us-west-2."
}

variable "wait_for_cluster_timeout" {
  default     = 300
  type        = number
  description = "A timeout (in seconds) to wait for cluster to be available."
}
