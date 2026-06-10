variable "cluster_name" {
  type        = string
  description = "EKS cluster name e.g. rideshare-prod-eks"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.32"
  description = "EKS Kubernetes version"
}

variable "private_app_subnet_ids" {
  type        = list(string)
  description = "Private app subnet IDs — from vpc remote state (private_app_subnet_ids_list)"
}

variable "eks_cluster_sg_id" {
  type        = string
  description = "EKS cluster SG ID — from security-groups remote state"
}

variable "vpc_cni_version" {
  type    = string
  default = "v1.19.2-eksbuild.1"
}

variable "coredns_version" {
  type    = string
  default = "v1.11.4-eksbuild.2"
}

variable "kube_proxy_version" {
  type    = string
  default = "v1.32.0-eksbuild.2"
}

variable "tags" {
  type    = map(string)
  default = {}
}
