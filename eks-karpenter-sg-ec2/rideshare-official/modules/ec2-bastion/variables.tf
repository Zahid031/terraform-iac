variable "name" {
  type        = string
  description = "Resource name prefix e.g. rideshare-prod"
}

variable "subnet_id" {
  type        = string
  description = "Private app subnet ID — no public IP needed, SSM handles access"
}

variable "bastion_sg_id" {
  type        = string
  description = "Bastion SG ID — from security-groups remote state"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "t3.small is enough for kubectl + aws cli usage"
}

variable "kubectl_version" {
  type        = string
  default     = "1.32.0"
  description = "Must match or be within 1 minor version of the EKS cluster"
}

variable "tags" {
  type    = map(string)
  default = {}
}
