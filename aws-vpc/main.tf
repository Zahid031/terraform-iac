# ─────────────────────────────────────────────────────────────────────
# VPC — networking: subnets, IGW, NAT, route tables
# ─────────────────────────────────────────────────────────────────────
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
}

# ─────────────────────────────────────────────────────────────────────
# Security Groups
# ─────────────────────────────────────────────────────────────────────

# ALB — accepts HTTP/HTTPS from the internet
module "sg_alb" {
  source         = "./modules/security_group"
  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  sg_name        = "alb"
  sg_description = "Load Balancer - public HTTP/HTTPS inbound"

  ingress_rules = [
    {
      description = "HTTP from internet"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "HTTPS from internet"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]
}

# App — accepts traffic from within the VPC (e.g. from ALB)
module "sg_app" {
  source         = "./modules/security_group"
  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  sg_name        = "app"
  sg_description = "Application servers - inbound from VPC only"

  ingress_rules = [
    {
      description = "App port from VPC"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    },
  ]
}

# RDS — accepts Postgres from private subnets only
module "sg_rds" {
  source         = "./modules/security_group"
  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  sg_name        = "rds"
  sg_description = "RDS - Postgres inbound from private subnets"

  ingress_rules = [
    {
      description = "Postgres from private subnets"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = var.private_subnet_cidrs
    },
  ]
}
