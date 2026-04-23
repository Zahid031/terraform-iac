
# modules/security-groups/outputs.tf

output "default_sg_id" {
  description = "ID of the default (tightened) security group"
  value       = aws_default_security_group.default.id
}

output "public_sg_id" {
  description = "ID of the public-facing security group"
  value       = aws_security_group.public.id
}

output "private_sg_id" {
  description = "ID of the private/internal security group"
  value       = aws_security_group.private.id
}
