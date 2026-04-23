output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.this[*].id
}

output "nat_public_ips" {
  description = "Elastic IP addresses of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}
