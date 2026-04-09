resource "aws_instance" "ubuntu" {
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"


  tags = {
    Name = "varInstance"
  }

}


resource "aws_instance" "test" {
  ami = "ami-020cba7c55df1f615"
  instance_type = "t3.micro"
  tags = {
    Name = "varInstance"
  }
  
}