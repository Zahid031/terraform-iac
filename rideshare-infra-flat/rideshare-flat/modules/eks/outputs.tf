output "cluster_name" {
  description = "EKS cluster name — consumed by karpenter module"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint (private only)"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_cert" {
  description = "Base64 encoded cluster CA certificate"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_oidc_issuer" {
  description = "OIDC issuer URL — consumed by karpenter module for IRSA"
  value       = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "OIDC provider ARN — consumed by karpenter module for IRSA trust policy"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "node_role_arn" {
  description = "Node IAM role ARN — consumed by karpenter module for PassRole permission"
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "Node IAM role name — used in EC2NodeClass spec.role"
  value       = aws_iam_role.node.name
}

output "node_instance_profile_arn" {
  description = "Node instance profile ARN — consumed by karpenter module"
  value       = aws_iam_instance_profile.node.arn
}
