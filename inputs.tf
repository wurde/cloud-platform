variable "cloud" {
  description = "What cloud do you want to deploy to? [aws (default), gcp]"
  type        = string
  default     = "aws"

  validation {
    condition = var.cloud == "aws" || var.cloud == "gcp"
    error_message = "The cloud must be either 'aws' or 'gcp'."
  }
}

variable "region" {
  description = "AWS or GCP region. Default is AWS us-west-2."
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster. Also used as a prefix in names of related resources."
  type        = string
  default     = ""
}

variable "wait_for_cluster_timeout" {
  description = "A timeout (in seconds) to wait for cluster to be available."
  type        = number
  default     = 300
}

variable "write_kubeconfig" {
  description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to kubeconfig_output_path."
  type        = bool
  default     = true
}
variable "kubeconfig_output_path" {
  description = "Where to save the Kubectl config file (if write_kubeconfig = true)."
  type        = string
  default     = "./"
}
variable "kubeconfig_file_permission" {
  description = "File permission of the Kubectl config file containing cluster configuration saved to `kubeconfig_output_path.`"
  type        = string
  default     = "0600"
}
variable "kubeconfig_aws_authenticator_command" {
  description = "Command to use to fetch AWS EKS credentials."
  type        = string
  default     = "aws-iam-authenticator"
}
variable "kubeconfig_aws_authenticator_command_args" {
  description = "Default arguments passed to the authenticator command. Defaults to [token -i $cluster_name]."
  type        = list(string)
  default     = []
}
variable "kubeconfig_aws_authenticator_additional_args" {
  description = "Any additional arguments to pass to the authenticator such as the role to assume. e.g. [\"-r\", \"MyEksRole\"]."
  type        = list(string)
  default     = []
}
variable "kubeconfig_aws_authenticator_env_variables" {
  description = "Environment variables that should be used when executing the authenticator. e.g. { AWS_PROFILE = \"eks\"}."
  type        = map(string)
  default     = {}
}
