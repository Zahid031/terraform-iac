provider "aws" {
  region = var.aws_region
  # Default tags applied automatically to every resource that supports them
  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Repository  = "github.com/zahid03/terraform-iac"
    }
  }
}
