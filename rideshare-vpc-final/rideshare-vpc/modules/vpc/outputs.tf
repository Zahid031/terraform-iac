output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

# Subnet IDs — maps (AZ → ID) and flat lists for different consumers
output "public_subnet_ids" {
  description = "Map of AZ → public subnet ID"
  value       = { for az, s in aws_subnet.public : az => s.id }
}

output "public_subnet_ids_list" {
  description = "List of public subnet IDs"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_app_subnet_ids" {
  description = "Map of AZ → private app subnet ID"
  value       = { for az, s in aws_subnet.private_app : az => s.id }
}

output "private_app_subnet_ids_list" {
  description = "List of private app subnet IDs (for EKS node groups, ALB)"
  value       = [for s in aws_subnet.private_app : s.id]
}

output "private_data_subnet_ids" {
  description = "Map of AZ → private data subnet ID"
  value       = { for az, s in aws_subnet.private_data : az => s.id }
}

output "private_data_subnet_ids_list" {
  description = "List of private data subnet IDs (for RDS, Redis, Kafka)"
  value       = [for s in aws_subnet.private_data : s.id]
}

# Route tables
output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public.id
}

output "private_route_table_ids" {
  description = "Map of AZ → private route table ID"
  value       = { for az, rt in aws_route_table.private : az => rt.id }
}

# NAT Gateways
output "nat_gateway_ids" {
  description = "Map of AZ → NAT Gateway ID"
  value       = { for az, n in aws_nat_gateway.this : az => n.id }
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IPs (whitelist for outbound)"
  value       = [for eip in aws_eip.nat : eip.public_ip]
}

# VPC Endpoints
output "vpc_endpoint_sg_id" {
  description = "Security group ID for interface endpoints (attach to workloads if needed)"
  value       = local.create_endpoint_sg ? aws_security_group.vpc_endpoints[0].id : null
}

output "s3_endpoint_id" {
  description = "S3 gateway endpoint ID"
  value       = var.enable_s3_endpoint ? aws_vpc_endpoint.s3[0].id : null
}
