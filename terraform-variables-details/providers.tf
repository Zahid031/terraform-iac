provider "aws" {
  region = var.AWS_REGION

  default_tags {
    tags = {
      Environment = "Dev"
      Project     = "TerraformBasics"
    }
  }
}
