
resource "aws_instance" "test-ec2" {
  ami           = var.ami-id
  instance_type = var.instance_type

  tags = {
    Name = "BasicsInstance"
  }
}


#call ami from map
# resource "aws_instance" "test-ec2" {
#   ami           = lookup(var.AMIS, var.AWS_REGION)
#   instance_type = var.instance_type 
#tags = {
#     Name = "BasicsInstance"
#   }
# }