# provider "aws" {
#   region = "us-east-1"
# }

# data "aws_ami" "ubuntu" {
#   most_recent = true
#   owners      = ["099720109477"] # Canonical (Ubuntu)

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-20.04-amd64-server-*"]
#   }
# }

# resource "aws_instance" "ubuntu" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t2.micro" # Free Tier eligible
#   key_name      = "ubuntu"   # Make sure you've already created this in AWS

#   tags = {
#     Name = "SimpleUbuntu"
#   }
# }

