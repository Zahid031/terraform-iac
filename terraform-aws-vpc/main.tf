###############################################################################
# main.tf — Root Module
# Orchestrates all child modules for the AWS VPC setup
###############################################################################

locals {
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  })
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  project_name         = var.project_name
  environment          = var.environment
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  tags                 = local.common_tags
}

###############################################################################
# Subnets Module
###############################################################################
module "subnets" {
  source = "./modules/subnets"

  vpc_id               = module.vpc.vpc_id
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
  environment          = var.environment
  igw_id               = module.vpc.internet_gateway_id
  tags                 = local.common_tags
}

###############################################################################
# NAT Gateway Module
###############################################################################
module "nat_gateway" {
  source = "./modules/nat-gateway"

  # Only create NAT if private subnets exist
  create_nat_gateway   = length(var.private_subnet_cidrs) > 0
  public_subnet_ids    = module.subnets.public_subnet_ids
  private_subnet_ids   = module.subnets.private_subnet_ids
  private_route_table_ids = module.subnets.private_route_table_ids
  project_name         = var.project_name
  environment          = var.environment
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.common_tags
}

###############################################################################
# Security Groups Module
###############################################################################
module "security_groups" {
  source = "./modules/security-groups"

  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}
