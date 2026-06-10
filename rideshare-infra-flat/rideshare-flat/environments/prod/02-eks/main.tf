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

module "eks" {
  source = "../../../modules/eks"

  cluster_name           = "${var.project}-${var.environment}-eks"
  kubernetes_version     = var.kubernetes_version
  private_app_subnet_ids = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids_list
  eks_cluster_sg_id      = data.terraform_remote_state.sg.outputs.eks_cluster_sg_id

  vpc_cni_version    = var.vpc_cni_version
  coredns_version    = var.coredns_version
  kube_proxy_version = var.kube_proxy_version

  tags = var.tags
}

# ── Outputs (consumed by karpenter layer) ────────────────────────────────────
output "cluster_name"              { value = module.eks.cluster_name }
output "cluster_endpoint"          { value = module.eks.cluster_endpoint }
output "cluster_ca_cert" {
  value     = module.eks.cluster_ca_cert
  sensitive = true
}
output "cluster_oidc_issuer"       { value = module.eks.cluster_oidc_issuer }
output "oidc_provider_arn"         { value = module.eks.oidc_provider_arn }
output "node_role_arn"             { value = module.eks.node_role_arn }
output "node_role_name"            { value = module.eks.node_role_name }
output "node_instance_profile_arn" { value = module.eks.node_instance_profile_arn }
