###############################################################################
# environments/prod/eks/main.tf
#
# Changes from previous version:
#   - No remote state: VPC/subnet IDs supplied via variables
#   - No external SGs: EKS module creates its own cluster + node SGs
#   - eks-pod-identity-agent addon enabled (required for Pod Identity)
#   - karpenter.sh/discovery tag on cluster + node group for EC2NodeClass lookup
###############################################################################

data "aws_caller_identity" "current" {}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = "${var.project}-${var.environment}-eks"
  kubernetes_version = var.kubernetes_version

  # ── Networking ────────────────────────────────────────────────────────────
  vpc_id     = var.vpc_id
  subnet_ids = var.private_app_subnet_ids

  endpoint_public_access  = true
  endpoint_private_access = false

  # ── Security Groups ───────────────────────────────────────────────────────
  # Let the module create the cluster and node SGs.
  # The cluster SG is automatically tagged with karpenter.sh/discovery
  # via the cluster-level tags block below, so EC2NodeClass can discover it.
  create_security_group      = true
  create_node_security_group = true

  # ── Auth ──────────────────────────────────────────────────────────────────
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  # ── Logging ───────────────────────────────────────────────────────────────
  create_cloudwatch_log_group = false

  # ── Addons ───────────────────────────────────────────────────────────────
  addons = {
    vpc-cni = {
      addon_version               = var.vpc_cni_version
      resolve_conflicts_on_update = "OVERWRITE"
      before_compute              = true
    }
    coredns = {
      addon_version               = var.coredns_version
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      addon_version               = var.kube_proxy_version
      resolve_conflicts_on_update = "OVERWRITE"
    }
    # Required for EKS Pod Identity (replaces IRSA for Karpenter and all
    # other controllers that use Pod Identity associations)
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  # ── System node group ─────────────────────────────────────────────────────
  # Runs Karpenter controller + other critical addons.
  # Tainted CriticalAddonsOnly=true:NoSchedule so workload pods never land here.
  eks_managed_node_groups = {
    system = {
      instance_types = ["t3.small"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2

      # Spread system nodes across the first two AZs
      subnet_ids    = slice(var.private_app_subnet_ids, 0, 2)
      capacity_type = "ON_DEMAND"

      taints = {
        dedicated = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }

      labels = { role = "system" }

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 50
            volume_type           = "gp3"
            encrypted             = true
            delete_on_termination = true
          }
        }
      }

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      tags = {
        role                     = "system"
        "karpenter.sh/discovery" = "${var.project}-${var.environment}-eks"
      }
    }
  }

  # karpenter.sh/discovery on the cluster propagates to the cluster SG and
  # node SG created by the module, so EC2NodeClass selectors work without
  # any manual SG tagging.
  tags = merge(var.tags, {
    "karpenter.sh/discovery" = "${var.project}-${var.environment}-eks"
  })
}
