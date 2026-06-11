variable "name" {
  type        = string
  description = "Resource name prefix (e.g. rideshare-prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID — passed in from environments/prod/security-groups/main.tf via remote state"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block — used for endpoint SG ingress rules"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name — written into node SG tags for Karpenter discovery"
}

variable "bastion_allowed_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDRs allowed SSH to bastion. Leave empty if using SSM Session Manager only."
}

variable "tags" {
  type    = map(string)
  default = {}
}
