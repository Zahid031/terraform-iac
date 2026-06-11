variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.32"
  description = "EKS Kubernetes version"
}

variable "vpc_cni_version" {
  type        = string
  default     = "v1.19.2-eksbuild.1"
  description = "VPC CNI addon version"
}

variable "coredns_version" {
  type        = string
  default     = "v1.11.4-eksbuild.2"
  description = "CoreDNS addon version"
}

variable "kube_proxy_version" {
  type        = string
  default     = "v1.32.0-eksbuild.2"
  description = "kube-proxy addon version"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources"
}
