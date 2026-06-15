# environments/prod/karpenter/provider.tf

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.75" }
  }
}

provider "aws" {
  region = var.region
  default_tags { tags = var.tags }
}
