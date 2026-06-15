# environments/prod/karpenter/backend.tf
#
# State is managed locally for now. Swap to S3 when ready:
#
# terraform {
#   backend "s3" {
#     bucket       = "rideshare-terraform-state-prod"
#     key          = "karpenter/terraform.tfstate"
#     region       = "ap-southeast-1"
#     encrypt      = true
#     use_lockfile = true
#   }
# }

terraform {
  backend "local" {}
}
