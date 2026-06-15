terraform {
  backend "s3" {
    bucket         = "rideshare-terraform-state-prod"
    key            = "vpc/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    use_lockfile   = true           # ← native S3 locking, no DynamoDB needed
    force_destroy = true           # ← allow terraform destroy to delete the state file
  }
}