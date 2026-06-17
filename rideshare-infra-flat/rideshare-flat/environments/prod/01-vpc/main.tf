module "vpc" {
  source = "../../../modules/vpc"

  name               = "${var.project}-${var.environment}"
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  cluster_name       = "${var.project}-${var.environment}-eks"

  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs

  # Prod: one NAT per AZ for full HA
  enable_nat_gateway = true
  single_nat_gateway = true

  # Gateway endpoints (free — always on)
  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = false

  # Interface endpoints — enable for EKS clusters (saves NAT costs at scale)
  enable_ecr_endpoints       = false
  enable_sts_endpoint        = false
  enable_ssm_endpoints       = false
  enable_cloudwatch_endpoint = false

  # Flow logs — on in prod
  enable_flow_logs         = false
  flow_logs_retention_days = 90

  tags = var.tags
}
