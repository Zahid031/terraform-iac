variable "aws_region" {
  type        = string
  description = "AWS region where resources will be created."
  default     = "ap-southeast-1"
}


variable "instance_name" {
  type        = string
  description = "Name tag for the EC2 instance."
} 

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
  default     = "t3.micro"

  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "instance_type must be one of: t2.micro, t3.micro, t3.small, t3.medium."
  }
}

variable "ami_id" {
  type        = string
  description = "AMI ID to use for the EC2 instance."
}

variable "key_name" {
  type        = string
  description = "Name for the AWS key pair (the .pem file will be saved with this name)."
}


variable "my_ip" {
  type        = string
  description = "Your public IP in CIDR notation (e.g. 103.155.179.51/32). Used to restrict SSH access."

  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.my_ip))
    error_message = "my_ip must be a valid CIDR block, e.g. 103.155.179.51/32."
  }
}

# ──────────────────────────────────────────
# Tags
# ──────────────────────────────────────────
variable "project" {
  type        = string
  description = "Project name — applied to all resource tags."
  default     = "my-project"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be one of: dev, staging, production."
  }
}
