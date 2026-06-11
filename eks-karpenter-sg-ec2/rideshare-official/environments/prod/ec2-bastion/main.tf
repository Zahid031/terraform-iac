# ── Read VPC outputs ─────────────────────────────────────────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "vpc/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

# ── Read security-groups outputs ──────────────────────────────────────────────
data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "security-groups/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

module "bastion" {
  source = "../../../modules/ec2-bastion"

  name          = "${var.project}-${var.environment}"
  subnet_id     = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids_list[0]
  bastion_sg_id = data.terraform_remote_state.sg.outputs.bastion_sg_id

  instance_type   = var.instance_type
  kubectl_version = var.kubectl_version
  tags            = var.tags
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "instance_id"         { value = module.bastion.instance_id }
output "private_ip"          { value = module.bastion.private_ip }
output "ssm_connect_command" { value = module.bastion.ssm_connect_command }
