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

variable "cluster_create_endpoint_private_access_sg_rule" {
  description = "Whether to create security group rules for the access to the Amazon EKS private API server endpoint. When is `true`, `cluster_endpoint_private_access_cidrs` must be setted."
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`."
  type        = list(string)
  default     = null
}

variable "cluster_endpoint_private_access_sg" {
  description = "List of security group IDs which can access the Amazon EKS private API server endpoint. To use this `cluster_endpoint_private_access` and `cluster_create_endpoint_private_access_sg_rule` must be set to `true`."
  type        = list(string)
  default     = null
}

variable "cluster_endpoint_private_access" {
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled."
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled. When it's set to `false` ensure to have a proper private access with `cluster_endpoint_private_access = true`."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  description = "Service ipv4 cidr for the kubernetes cluster"
  type        = string
  default     = null
}

variable "cluster_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for cluster egress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "workers_egress_cidrs" {
  description = "List of CIDR blocks that are permitted for workers egress traffic."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "worker_groups" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Configurations."
  type        = list(any)
  default     = []
}
variable "workers_group_defaults" {
  description = "Override default values for target groups. See workers_group_defaults_defaults in local.tf for valid keys."
  type        = any
  default     = {}
}
variable "worker_groups_launch_template" {
  description = "A list of maps defining worker group configurations to be defined using AWS Launch Templates."
  type        = any
  default     = []
}

variable "workers_additional_policies" {
  description = "Additional policies to be added to workers."
  type        = list(string)
  default     = []
}

variable "node_groups_defaults" {
  description = "Map of values to be applied to all node groups."
  type        = any
  default     = {}
}

variable "node_groups" {
  description = "Map of map of node groups to create."
  type        = any
  default     = {}
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
