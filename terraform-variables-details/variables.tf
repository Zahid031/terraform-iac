variable "AWS_REGION" {
  type    = string
  default = "ap-southeast-1"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami-id" {
  type        = string
  description = "The AMI ID for the EC2 instance"
  default     = "abc"
}


variable "Security-Group" {
  type = list
  default = ["sg-0a1b2c3d4e5f6g7h8i9j"]  
}
#map
variable "AMIS" {
  type = map(string)
  default = {
    "us-east-1" = "ami-0123456789abcdef0"
    "us-west-2" = "ami-0fedcba9876543210"
  }
  
}