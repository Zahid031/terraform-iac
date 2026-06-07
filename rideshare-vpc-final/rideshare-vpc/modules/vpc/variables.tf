variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to use (determines subnet and NAT GW count)"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets — one per AZ"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private app subnets (EKS, workloads) — one per AZ"
  type        = list(string)
}

variable "private_data_subnet_cidrs" {
  description = "CIDR blocks for private data subnets (RDS, Redis, Kafka) — one per AZ"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name — used for Karpenter and EKS subnet discovery tags"
  type        = string
  default     = ""
}

# NAT Gateway
variable "enable_nat_gateway" {
  description = "Create NAT gateways for private subnet internet access"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use one NAT GW in the first AZ instead of one per AZ. Saves cost; not HA."
  type        = bool
  default     = false
}

# VPC Endpoints — Gateway (free)
variable "enable_s3_endpoint" {
  description = "Enable S3 gateway endpoint (free — keeps S3 traffic off NAT)"
  type        = bool
  default     = true
}

variable "enable_dynamodb_endpoint" {
  description = "Enable DynamoDB gateway endpoint (free)"
  type        = bool
  default     = false
}

# VPC Endpoints — Interface (charged per hour + data)
variable "enable_ecr_endpoints" {
  description = "Enable ECR interface endpoints (ecr.api + ecr.dkr). Recommended for EKS."
  type        = bool
  default     = false
}

variable "enable_sts_endpoint" {
  description = "Enable STS interface endpoint. Recommended for EKS IRSA."
  type        = bool
  default     = false
}

variable "enable_ssm_endpoints" {
  description = "Enable SSM interface endpoints (ssm + ssmmessages + ec2messages)"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_endpoint" {
  description = "Enable CloudWatch Logs interface endpoint"
  type        = bool
  default     = false
}

# Flow Logs
variable "enable_flow_logs" {
  description = "Enable VPC flow logs to CloudWatch Logs"
  type        = bool
  default     = false
}

variable "flow_logs_retention_days" {
  description = "CloudWatch log retention in days for flow logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.flow_logs_retention_days)
    error_message = "Must be a valid CloudWatch retention period."
  }
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
