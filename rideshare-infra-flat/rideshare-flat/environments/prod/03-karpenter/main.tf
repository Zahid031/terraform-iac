# ── Read EKS outputs ─────────────────────────────────────────────────────────
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "eks/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

module "karpenter" {
  source = "../../../modules/karpenter"

  cluster_name              = data.terraform_remote_state.eks.outputs.cluster_name
  oidc_provider_arn         = data.terraform_remote_state.eks.outputs.oidc_provider_arn
  oidc_issuer_url           = data.terraform_remote_state.eks.outputs.cluster_oidc_issuer
  node_role_arn             = data.terraform_remote_state.eks.outputs.node_role_arn
  node_instance_profile_arn = data.terraform_remote_state.eks.outputs.node_instance_profile_arn

  tags = var.tags
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "controller_role_arn"    { value = module.karpenter.controller_role_arn }
output "interruption_queue_url" { value = module.karpenter.interruption_queue_url }
output "interruption_queue_name"{ value = module.karpenter.interruption_queue_name }
