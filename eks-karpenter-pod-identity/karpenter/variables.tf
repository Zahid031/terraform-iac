# environments/prod/karpenter/variables.tf

variable "region" {
  type        = string
  description = "AWS region"
}

# ── EKS inputs (replaces remote state lookup) ────────────────────────────────

variable "cluster_name" {
  type        = string
  description = "EKS cluster name  copy from eks layer: terraform output cluster_name"
}

# ── Karpenter Helm ───────────────────────────────────────────────────────────

variable "karpenter_version" {
  type        = string
  default     = "1.9.0"
  description = "Karpenter Helm chart version (must match controller image tag)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources"
}
