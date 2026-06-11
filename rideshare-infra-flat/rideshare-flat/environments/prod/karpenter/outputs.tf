###############################################################################
# environments/prod/karpenter/outputs.tf
###############################################################################

output "controller_role_arn" {
  description = "Karpenter controller IAM role ARN — paste into karpenter-helm-values.yaml"
  value       = module.karpenter.iam_role_arn
}

output "interruption_queue_url" {
  description = "SQS interruption queue URL"
  value       = module.karpenter.queue_url
}

output "interruption_queue_name" {
  description = "SQS queue name — paste into karpenter-helm-values.yaml"
  value       = module.karpenter.queue_name
}

output "node_iam_role_name" {
  description = "Node IAM role name — use in EC2NodeClass spec.role"
  value       = module.karpenter.node_iam_role_name
}

output "node_iam_role_arn" {
  description = "Node IAM role ARN"
  value       = module.karpenter.node_iam_role_arn
}