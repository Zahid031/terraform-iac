###############################################################################
# environments/prod/karpenter/main.tf
#
# Changes from previous version:
#   - No remote state: cluster_name and node_iam_role_name supplied via variables
#   - Pod Identity only: create_pod_identity_association = true (default in v21)
#   - No IRSA: oidc_provider_arn / irsa_* arguments removed entirely
#   - Karpenter reuses the node IAM role created by the EKS layer
#   - Instance profile already created by EKS layer → create_instance_profile = false
###############################################################################

data "aws_caller_identity" "current" {}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = var.cluster_name

  # ── Pod Identity (no IRSA) ────────────────────────────────────────────────
  # The eks-pod-identity-agent addon (installed in the EKS layer) handles
  # credential injection. No serviceAccount annotation is needed on the
  # Karpenter SA — Pod Identity binds the role to the SA via the association.
  create_pod_identity_association = true
  enable_inline_policy            = true

  # ── Node IAM role ────────────────────────────────────────────────────────
  # Create a dedicated IAM role for Karpenter-launched nodes.
  # This is separate from the system node group role so Karpenter nodes
  # have their own role and can be scoped independently.
  create_node_iam_role = true

  node_iam_role_name   = "${var.cluster_name}-karpenter-node"
  node_iam_role_use_name_prefix = false

  # Instance profile is created by the karpenter module alongside the node role
  create_instance_profile = true

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}
