# environments/prod/vpc/
#
# This folder contains your existing VPC Terraform code (rideshare-vpc/).
# It is listed here as a placeholder — DO NOT copy files here or re-apply.
#
# State location: s3://rideshare-terraform-state-prod/vpc/terraform.tfstate
#
# All other layers read this state via:
#
#   data "terraform_remote_state" "vpc" {
#     backend = "s3"
#     config  = {
#       bucket = "rideshare-terraform-state-prod"
#       key    = "vpc/terraform.tfstate"
#       region = "ap-southeast-1"
#     }
#   }
#
# VPC outputs available to downstream layers:
#   .outputs.vpc_id
#   .outputs.vpc_cidr
#   .outputs.private_app_subnet_ids_list
#   .outputs.private_data_subnet_ids_list
#   .outputs.public_subnet_ids_list
#   .outputs.private_route_table_ids        (map of AZ -> RT ID)
#   .outputs.nat_gateway_public_ips
#   .outputs.vpc_endpoint_sg_id
