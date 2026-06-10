terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = { source = "hashicorp/aws" }
    tls = { source = "hashicorp/tls"}
  }
}

provider "aws" {
  region = var.region
  default_tags { tags = var.tags }
}
