# variables.tf — Root Module Input Declarations
# Only type, description, and optional defaults go here — no actual values

variable "project_name" {
    type = string
    description = "Name of the project - used in all resource names and tags"
    default = "terraform_vpc"
  
}
variable "environment" {
    type = string
    description = "Deployment environment (dev | staging | prod)"
    validation {
      condition = contains(["dev", "staging", "prod"], var.environment)
      error_message = "Environment must be one of: dev, staging, prod"
    }
  
}


variable "aws_region" {
    type = string
    description = "AWS region where the VPC will be created"
    default = "ap-southeast-1"  
}

# vpc variables

variable "vpc_cidr" {
    type = string
    description = "CIDR block for the VPC (e.g 10.0.0.0/16)"
    default = "10.0.0.0/16"
    validation {
      condition = can(cidrhost(var.vpc_cidr,0))
      error_message = "vpc_cidr must be a valid IPv4 CIDR block."
    }
  
}

variable "enable_dns_hostnames" {
    type = bool
    description = "Whether to enable DNS hostnames for the VPC"
    default = false
}

variable "enable_dns_support" {
    type = bool
    description = "Whether to enable DNS support for the VPC"
    default = true
}

# subnets variables

variable "availability_zones" {
    type = list(string)
    description = "List of AZs to use for subnets"
    default = [ "ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c" ]
  
}


variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets — one per AZ"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets — one per AZ"
  type        = list(string)
  default     = ["10.0.11.0/21", "10.0.21.0/21", "10.0.31.0/21"]
}


# NAT Gateway

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets (cost-saving for non-prod)"
  type        = bool
  default     = false
}
# Tags
variable "tags" {
  description = "Additional tags to merge with the common tags applied to all resources"
  type        = map(string)
  default     = {}
}
