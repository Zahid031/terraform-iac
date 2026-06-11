###############################################################################
# environments/prod/karpenter/main.tf
#
# Uses the official karpenter submodule from terraform-aws-modules/eks/aws.
# Reads EKS outputs from remote state — no EKS resources created here.
# Creates:
#   - Karpenter controller IAM role (IRSA)
#   - Scoped IAM policy for controller (EC2, SQS, IAM PassRole, EKS Describe)
#   - SQS interruption queue (spot + health + state-change events)
#   - EventBridge rules routing events to SQS
###############################################################################

data "aws_caller_identity" "current" {}

# ── Remote state: EKS (read-only) ────────────────────────────────────────────
data "terraform_remote_state" "eks" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "eks/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

###############################################################################
# Karpenter — official registry submodule
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest/submodules/karpenter
###############################################################################
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name

  # ── IRSA — controller pod gets AWS credentials via service account ────────────
  enable_irsa            = true
  irsa_oidc_provider_arn = data.terraform_remote_state.eks.outputs.oidc_provider_arn

  # ── Node IAM role — created in the EKS layer, reuse it here ──────────────────
  # The controller needs PassRole on this ARN to launch nodes.
  create_node_iam_role = false
  node_iam_role_arn    = data.terraform_remote_state.eks.outputs.node_role_arn

  # ── Instance profile — created by the EKS module, reuse it ───────────────────
  create_instance_profile = false

  # ── Enable v1 permissions (required for Karpenter >= 1.0) ────────────────────
  enable_v1_permissions = true

  tags = var.tags
}
