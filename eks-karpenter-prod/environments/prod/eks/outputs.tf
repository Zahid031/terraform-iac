###############################################################################
# environments/prod/eks/outputs.tf
# All outputs consumed by the karpenter layer via remote state.
###############################################################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server private endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_cert" {
  description = "Base64-encoded cluster CA certificate"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL — used by karpenter layer for IRSA trust policy"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN — used by karpenter layer for IRSA trust policy"
  value       = module.eks.oidc_provider_arn
}

output "node_role_arn" {
  description = "Node IAM role ARN — passed to karpenter module (PassRole permission)"
  value       = module.eks.eks_managed_node_groups["system"].iam_role_arn
}

output "node_role_name" {
  description = "Node IAM role name — used in EC2NodeClass spec.role"
  value       = module.eks.eks_managed_node_groups["system"].iam_role_name
}

output "node_instance_profile_arn" {
  description = "Node instance profile ARN — passed to karpenter module"
  value       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${module.eks.cluster_name}-system"
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = module.eks.cluster_version
}
