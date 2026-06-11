###############################################################################
# environments/prod/karpenter/main.tf
# v21 karpenter submodule — IRSA removed, Pod Identity is default
###############################################################################

data "aws_caller_identity" "current" {}

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
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "21.23.0"

  cluster_name = data.terraform_remote_state.eks.outputs.cluster_name

  # Pod Identity is now the default in v21 — no IRSA config needed
  # eks-pod-identity-agent addon must be installed (it is, in your eks layer)
  create_pod_identity_association = true
  enable_inline_policy = true

  # Reuse the node IAM role created by the EKS layer
  create_node_iam_role = true
  # node_iam_role_arn    = data.terraform_remote_state.eks.outputs.node_role_arn

  # Instance profile already exists from EKS layer
  create_instance_profile = false

  # SSM access on Karpenter-launched nodes
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}