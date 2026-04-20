
resource "aws_instance" "test-ec2" {
  ami           = var.ami-id
  instance_type = var.instance_type

  tags = {
    Name = "BasicsInstance"
  }
}
