# modules/nat-gateway/variables.tf

variable "create_nat_gateway" {
  description = "Whether to create a NAT gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets (cost-saving for non-prod)"
  type        = bool
  default     = true
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where NAT gateways will be created"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (used for count reference)"
  type        = list(string)
}

variable "private_route_table_ids" {
  description = "Private route table IDs to add NAT routes to"
  type        = list(string)
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
