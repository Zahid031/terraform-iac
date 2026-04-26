# ─────────────────────────────────────────────────────────────────────
# VPC
# ─────────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

# ─────────────────────────────────────────────────────────────────────
# Subnets
# ─────────────────────────────────────────────────────────────────────
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# ─────────────────────────────────────────────────────────────────────
# Gateways
# ─────────────────────────────────────────────────────────────────────
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "nat_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = module.vpc.nat_public_ips
}

# ─────────────────────────────────────────────────────────────────────
# Security Groups
# ─────────────────────────────────────────────────────────────────────
output "sg_alb_id" {
  description = "Security Group ID for the ALB"
  value       = module.sg_alb.security_group_id
}

output "sg_app_id" {
  description = "Security Group ID for application servers"
  value       = module.sg_app.security_group_id
}

output "sg_rds_id" {
  description = "Security Group ID for RDS"
  value       = module.sg_rds.security_group_id
}
