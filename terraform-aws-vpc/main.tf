resource "aws_vpc" "terraform_vpc" {
    cidr_block = var.cidr_block
    tags = {
        Name = "terraform_vpc" 
    }
  
}