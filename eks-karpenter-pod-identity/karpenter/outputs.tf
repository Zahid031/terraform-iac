# environments/prod/karpenter/outputs.tf
#
# After `terraform apply`, use these values to fill in:
#   - karpenter-helm-values.yaml  (clusterName, interruptionQueue)
#   - node-class.yaml             (spec.role)

output "controller_role_arn" {
  description = "Karpenter controller IAM role ARN (Pod Identity — no helm annotation needed)"
  value       = module.karpenter.iam_role_arn
}

output "interruption_queue_url" {
  description = "SQS interruption queue URL"
  value       = module.karpenter.queue_url
}

output "interruption_queue_name" {
  description = "SQS queue name — paste into karpenter-helm-values.yaml settings.interruptionQueue"
  value       = module.karpenter.queue_name
}

output "node_iam_role_name" {
  description = "Karpenter node IAM role name — paste into node-class.yaml spec.role"
  value       = module.karpenter.node_iam_role_name
}

output "node_iam_role_arn" {
  description = "Karpenter node IAM role ARN"
  value       = module.karpenter.node_iam_role_arn
}

output "instance_profile_name" {
  description = "EC2 instance profile name created for Karpenter nodes"
  value       = module.karpenter.instance_profile_name
}
