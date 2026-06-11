# environments/prod/eks/outputs.tf

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca_cert" {
  value     = module.eks.cluster_certificate_authority_data
  sensitive = true
}

output "cluster_oidc_issuer" {
  value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "node_role_arn" {
  value = module.eks.eks_managed_node_groups["system"].iam_role_arn
}

output "node_role_name" {
  value = module.eks.eks_managed_node_groups["system"].iam_role_name
}

output "node_instance_profile_arn" {
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${module.eks.cluster_name}-system"
}