# ── Read VPC outputs (read-only, never modified here) ────────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "vpc/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

module "security_groups" {
  source = "../../../modules/security-groups"

  name         = "${var.project}-${var.environment}"
  cluster_name = "${var.project}-${var.environment}-eks"
  vpc_id       = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_cidr     = data.terraform_remote_state.vpc.outputs.vpc_cidr

  bastion_allowed_cidrs = var.bastion_allowed_cidrs
  tags                  = var.tags
}

# ── Outputs (consumed by eks and ec2-bastion layers) ─────────────────────────
output "eks_cluster_sg_id" { value = module.security_groups.eks_cluster_sg_id }
output "eks_nodes_sg_id"   { value = module.security_groups.eks_nodes_sg_id }
output "alb_sg_id"         { value = module.security_groups.alb_sg_id }
output "data_plane_sg_id"  { value = module.security_groups.data_plane_sg_id }
output "bastion_sg_id"     { value = module.security_groups.bastion_sg_id }
