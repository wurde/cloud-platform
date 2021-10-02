variable "cloud" {
  default     = "aws"
  type        = string
  description = "What cloud do you want to deploy to? [aws (default), google]"

  validation {
    condition = var.cloud == "aws" || var.cloud == "google"
    error_message = "The cloud must be either 'aws' or 'google'."
  }
}
