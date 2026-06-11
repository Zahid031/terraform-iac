variable "region" {
  type        = string
  description = "AWS region"
}

variable "karpenter_version" {
  type        = string
  default     = "1.3.3"
  description = "Karpenter Helm chart version"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources"
}
