# environments/prod/eks/outputs.tf
#
# After `terraform apply`, copy these values into karpenter/terraform.tfvars

output "cluster_name" {
  description = "EKS cluster name — set as karpenter.cluster_name tfvar"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint — set as karpenter.cluster_endpoint tfvar"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_cert" {
  description = "Base64 cluster CA certificate"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "node_iam_role_name" {
  description = "System node group IAM role name — used in EC2NodeClass spec.role"
  value       = module.eks.eks_managed_node_groups["system"].iam_role_name
}

output "node_iam_role_arn" {
  description = "System node group IAM role ARN"
  value       = module.eks.eks_managed_node_groups["system"].iam_role_arn
}

output "node_instance_profile_arn" {
  description = "System node instance profile ARN"
  value       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${module.eks.cluster_name}-system"
}
