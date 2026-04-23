# backend.tf — Remote State Configuration (S3)

# IMPORTANT: Run `terraform init` after changing backend config.

terraform {
  backend "s3" {
    bucket = "terraform-bucket-test-10"
    key = "vpc/terraform.tfstate"
    region = "ap-southeast-1"
  }
}