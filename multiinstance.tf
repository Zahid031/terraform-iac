resource "aws_instance" "ubuntu1" {
    count = 2
  ami           = "ami-020cba7c55df1f615"
  instance_type = "t2.micro"



tags = {
    Name = "MultiInstanceUbuntu-${count.index + 1}"
}

}