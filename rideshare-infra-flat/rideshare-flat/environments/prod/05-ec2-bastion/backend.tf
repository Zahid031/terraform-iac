terraform {
  backend "s3" {
    bucket       = "rideshare-terraform-state-prod"
    key          = "ec2-bastion/terraform.tfstate"
    region       = "ap-southeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
