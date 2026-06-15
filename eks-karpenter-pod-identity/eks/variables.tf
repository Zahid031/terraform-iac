# environments/prod/eks/variables.tf

variable "project" {
  type        = string
  description = "Project name (e.g. rideshare)"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. prod)"
}

variable "region" {
  type        = string
  description = "AWS region"
}

# ── Network inputs (replaces remote state lookup) ────────────────────────────

variable "vpc_id" {
  type        = string
  description = "VPC ID — copy from VPC layer output"
}

variable "private_app_subnet_ids" {
  type        = list(string)
  description = "Private app subnet IDs (3 subnets, one per AZ) — copy from VPC layer output"
}

# ── Kubernetes ───────────────────────────────────────────────────────────────

variable "kubernetes_version" {
  type        = string
  default     = "1.32"
  description = "EKS Kubernetes version"
}

# ── Addon versions ───────────────────────────────────────────────────────────
# Pin to explicit versions. Check latest at:
# https://docs.aws.amazon.com/eks/latest/userguide/add-ons-images.html

variable "vpc_cni_version" {
  type        = string
  default     = "v1.22.1-eksbuild.2"
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
