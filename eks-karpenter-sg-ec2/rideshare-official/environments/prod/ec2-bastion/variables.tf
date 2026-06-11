variable "project"         { type = string }
variable "environment"     { type = string }
variable "region"          { type = string }
variable "instance_type"   { type = string; default = "t3.small" }
variable "kubectl_version" { type = string; default = "1.32.0" }
variable "tags"            { type = map(string); default = {} }
