resource "aws_instance" "ubuntu" {
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"

}
