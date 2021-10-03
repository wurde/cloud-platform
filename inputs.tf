variable "cloud" {
  default     = "aws"
  type        = string
  description = "What cloud do you want to deploy to? [aws (default), gcp]"

  validation {
    condition = var.cloud == "aws" || var.cloud == "gcp"
    error_message = "The cloud must be either 'aws' or 'gcp'."
  }
}
