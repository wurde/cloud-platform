variable "cloud" {
  description = "What cloud do you want to deploy to? [aws (default), gcp]"
  type        = string
  default     = "aws"

  validation {
    condition     = var.cloud == "aws" || var.cloud == "gcp"
    error_message = "The cloud must be either 'aws' or 'gcp'."
  }
}

variable "region" {
  description = "AWS or GCP region. Default is AWS us-east-2."
  type        = string
  default     = "us-east-2"
}

variable "cluster_version" {
  description = "Kubernetes version to use for the EKS cluster."
  type        = string
  default     = "1.21"
}

variable "wait_for_cluster_timeout" {
  description = "A timeout (in seconds) to wait for cluster to be available."
  type        = number
  default     = 300
}

variable "cluster_enabled_log_types" {
  description = "A list of the desired control plane logging to enable. For more information, see Amazon EKS Control Plane Logging documentation (https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)"
  type        = list(string)
  default     = []
}
variable "cluster_log_kms_key_id" {
  description = "If a KMS Key ARN is set, this key will be used to encrypt the corresponding log group. Please be sure that the KMS Key has an appropriate key policy (https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/encrypt-log-data-kms.html)"
  type        = string
  default     = ""
}
variable "cluster_log_retention_in_days" {
  description = "Number of days to retain log events. Default retention - 90 days."
  type        = number
  default     = 90
}

variable "node_groups" {
  description = "Map of managed EKS node groups to create."
  type        = any
  default     = {}
}
variable "node_groups_defaults" {
  description = "Map of values to be applied to all EKS node groups."
  type        = any
  default     = {}
}

variable "map_iam_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_iam_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_aws_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster."
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources. Tags added to launch configuration or templates override these values for ASG Tags only."
  type        = map(string)
  default     = {}
}
