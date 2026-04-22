terraform {
  backend "s3" {
    bucket = "terraform-bucket-test-10"
    key    = "dev/terraform.tfstate"
    region = "ap-southeast-1"
  }
}