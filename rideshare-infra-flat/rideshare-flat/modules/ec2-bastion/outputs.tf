output "instance_id" {
  description = "Bastion instance ID — use in ssm start-session"
  value       = aws_instance.bastion.id
}

output "private_ip" {
  description = "Bastion private IP (for reference, not needed for SSM access)"
  value       = aws_instance.bastion.private_ip
}

output "bastion_role_arn" {
  description = "Bastion IAM role ARN"
  value       = aws_iam_role.bastion.arn
}

output "ssm_connect_command" {
  description = "Ready-to-run SSM connect command"
  value       = "aws ssm start-session --target ${aws_instance.bastion.id} --region ap-southeast-1"
}
