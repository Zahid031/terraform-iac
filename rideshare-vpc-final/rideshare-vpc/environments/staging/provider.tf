terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "rideshare-terraform-state"
    key            = "staging/vpc/terraform.tfstate" # change per env
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "rideshare-terraform-locks"
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
