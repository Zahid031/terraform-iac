terraform {
  required_version = "1.15.5"
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

provider "aws" {
  region = var.region
  default_tags { tags = var.tags }
}
