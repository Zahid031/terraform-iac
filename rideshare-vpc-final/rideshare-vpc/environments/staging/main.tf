module "vpc" {
  source = "../../modules/vpc"

  name               = "${var.project}-${var.environment}"
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  cluster_name       = "${var.project}-${var.environment}-eks"

  public_subnet_cidrs       = var.public_subnet_cidrs
  private_app_subnet_cidrs  = var.private_app_subnet_cidrs
  private_data_subnet_cidrs = var.private_data_subnet_cidrs

  # Staging: single NAT saves ~$100/month vs 3
  enable_nat_gateway = true
  single_nat_gateway = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = false

  enable_ecr_endpoints       = true
  enable_sts_endpoint        = true
  enable_ssm_endpoints       = false
  enable_cloudwatch_endpoint = false

  enable_flow_logs         = true
  flow_logs_retention_days = 14

  tags = var.tags
}

variable "project"     { type = string; default = "rideshare" }
variable "environment" { type = string; default = "staging" }
variable "region"      { type = string; default = "ap-southeast-1" }
variable "vpc_cidr"    { type = string; default = "10.1.0.0/16" }
variable "availability_zones"       { type = list(string) }
variable "public_subnet_cidrs"      { type = list(string) }
variable "private_app_subnet_cidrs"  { type = list(string) }
variable "private_data_subnet_cidrs" { type = list(string) }
variable "tags" { type = map(string); default = {} }

output "vpc_id"                       { value = module.vpc.vpc_id }
output "private_app_subnet_ids_list"  { value = module.vpc.private_app_subnet_ids_list }
output "private_data_subnet_ids_list" { value = module.vpc.private_data_subnet_ids_list }
output "nat_gateway_public_ips"       { value = module.vpc.nat_gateway_public_ips }
