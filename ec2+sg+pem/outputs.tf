# ──────────────────────────────────────────
# Instance Details
# ──────────────────────────────────────────
output "instance_id" {
  description = "The EC2 instance ID."
  value       = aws_instance.ec2.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = aws_instance.ec2.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the EC2 instance."
  value       = aws_instance.ec2.public_dns
}

# ──────────────────────────────────────────
# SSH Connection Command (ready to copy-paste)
# ──────────────────────────────────────────
output "ssh_command" {
  description = "Copy-paste this command to SSH into your instance."
  value       = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.ec2.public_ip}"
}

# ──────────────────────────────────────────
# Network Info
# ──────────────────────────────────────────
output "default_vpc_id" {
  description = "ID of the default VPC used."
  value       = data.aws_vpc.default.id
}

output "subnet_id" {
  description = "ID of the default subnet used."
  value       = tolist(data.aws_subnets.default.ids)[0]
}

output "security_group_id" {
  description = "ID of the security group attached to the instance."
  value       = aws_security_group.ec2_sg.id
}
