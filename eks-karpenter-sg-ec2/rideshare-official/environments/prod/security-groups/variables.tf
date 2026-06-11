variable "project"     { type = string }
variable "environment" { type = string }
variable "region"      { type = string }

variable "bastion_allowed_cidrs" {
  type    = list(string)
  default = []
}

variable "tags" { type = map(string); default = {} }
