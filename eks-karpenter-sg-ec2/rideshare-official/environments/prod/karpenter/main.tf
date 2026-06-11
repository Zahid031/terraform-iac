###############################################################################
# environments/prod/karpenter/main.tf
# Uses the official karpenter sub-module that ships inside
# terraform-aws-modules/eks/aws//modules/karpenter
# It creates: Karpenter controller IAM role (IRSA or Pod Identity),
# SQS interruption queue, and all EventBridge rules — exactly what your
# custom module did, but with the upstream project maintaining it.
###############################################################################

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

data "aws_caller_identity" "current" {}

###############################################################################
# Official Karpenter sub-module
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter
###############################################################################
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name

  # IRSA — same mechanism as your custom module
  enable_irsa            = true
  irsa_oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn

  # The module handles the full controller IAM policy, SQS queue,
  # and EventBridge rules (spot interruption, state change, scheduled change).

  # Node IAM role already created by the EKS layer — pass it in so the
  # controller's IAM policy gets the correct PassRole + instance-profile ARNs.
  create_node_iam_role          = false
  node_iam_role_arn             = data.terraform_remote_state.eks.outputs.node_role_arn

  # Instance profile created by the EKS module — tell Karpenter where it is
  create_instance_profile = false

  tags = var.tags
}

# ── Outputs ───────────────────────────────────────────────────────────────────
output "controller_role_arn"       { value = module.karpenter.iam_role_arn }
output "interruption_queue_url"    { value = module.karpenter.queue_url }
output "interruption_queue_name"   { value = module.karpenter.queue_name }
output "node_iam_role_arn"         { value = module.karpenter.node_iam_role_arn }
output "node_iam_role_name"        { value = module.karpenter.node_iam_role_name }
output "instance_profile_arn"      { value = module.karpenter.instance_profile_arn }
