output "controller_role_arn" {
  description = "Karpenter controller IAM role ARN — paste into karpenter-helm-values.yaml"
  value       = aws_iam_role.controller.arn
}

output "interruption_queue_url" {
  description = "SQS interruption queue URL — set in Helm values settings.interruptionQueue"
  value       = aws_sqs_queue.interruption.id
}

output "interruption_queue_name" {
  description = "SQS queue name only — used in Helm values (not full URL)"
  value       = aws_sqs_queue.interruption.name
}

output "interruption_queue_arn" {
  description = "SQS interruption queue ARN"
  value       = aws_sqs_queue.interruption.arn
}
