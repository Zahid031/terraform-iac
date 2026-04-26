terraform {
  backend "s3" {
    bucket = "terraform-bucket-test-10"
    key    = "dev-1/terraform.tfstate"
    region = "ap-southeast-1"
    use_lockfile = true
  }
}