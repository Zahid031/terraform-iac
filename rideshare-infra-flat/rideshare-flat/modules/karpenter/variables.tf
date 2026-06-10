variable "cluster_name" {
  type        = string
  description = "EKS cluster name — from eks remote state"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN — from eks remote state, used for IRSA trust policy"
}

variable "oidc_issuer_url" {
  type        = string
  description = "OIDC issuer URL — from eks remote state, used to build IRSA condition"
}

variable "node_role_arn" {
  type        = string
  description = "Node IAM role ARN — from eks remote state, controller needs PassRole on this"
}

variable "node_instance_profile_arn" {
  type        = string
  description = "Node instance profile ARN — from eks remote state"
}

variable "tags" {
  type    = map(string)
  default = {}
}
