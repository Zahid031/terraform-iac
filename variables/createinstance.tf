resource "aws_instance" "ubuntu" {
  ami           = "ami-0e7ff22101b84bcff"
  instance_type = "t3.micro"


  tags = {
    Name = "varInstance"
  }

}


