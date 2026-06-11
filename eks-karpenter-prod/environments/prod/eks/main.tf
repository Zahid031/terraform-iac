###############################################################################
# environments/prod/eks/main.tf
#
# Uses the official terraform-aws-modules/eks/aws (~> 20.0).
# Wires your existing VPC and security-groups layers via remote state.
# Creates:
#   - Private EKS cluster (no public endpoint)
#   - 2-node ON_DEMAND system node group (coreDNS, kube-proxy, Karpenter pods)
#   - EKS add-ons (vpc-cni, coredns, kube-proxy, pod-identity-agent)
#   - OIDC provider (used by Karpenter IRSA in the karpenter layer)
#   - Node IAM role + instance profile (passed to karpenter layer)
###############################################################################

data "aws_caller_identity" "current" {}

# ── Remote state: VPC (read-only, never modified here) ───────────────────────
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "vpc/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

# ── Remote state: security-groups (read-only) ─────────────────────────────────
data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "security-groups/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

###############################################################################
# EKS Cluster — official registry module
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
###############################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project}-${var.environment}-eks"
  cluster_version = var.kubernetes_version

  # ── Networking — your existing VPC ──────────────────────────────────────────
  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids_list

  # ── Private cluster — no public API endpoint ─────────────────────────────────
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  # ── Security groups — use your existing SGs, skip module-created ones ────────
  # The module creates its own cluster SG by default; we disable that and attach
  # yours instead so all rules stay managed in the security-groups layer.
  create_cluster_security_group = false
  cluster_security_group_id     = data.terraform_remote_state.sg.outputs.eks_cluster_sg_id

  create_node_security_group = false
  node_security_group_id     = data.terraform_remote_state.sg.outputs.eks_nodes_sg_id

  # ── Authentication ────────────────────────────────────────────────────────────
  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true

  # ── Control plane logs ────────────────────────────────────────────────────────
  cluster_enabled_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  # ── Add-ons ───────────────────────────────────────────────────────────────────
  cluster_addons = {
    # vpc-cni must be ready before any nodes join the cluster
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
    # Required for Karpenter Pod Identity (modern replacement for IRSA)
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  # ── System node group ─────────────────────────────────────────────────────────
  # 2 dedicated ON_DEMAND nodes for: coredns, kube-proxy, karpenter controller,
  # and any other critical add-ons. Tainted so app pods never land here.
  # Karpenter provisions ALL other nodes dynamically.
  eks_managed_node_groups = {
    system = {
      # t3.medium: 2 vCPU / 4 GB — sufficient for system pods
      instance_types = ["t3.medium"]

      # Fixed at 2 — one per AZ, no autoscaling
      min_size     = 2
      max_size     = 2
      desired_size = 2

      # Spread across first 2 AZs for HA
      # ap-southeast-1a and ap-southeast-1b
      subnet_ids = slice(
        data.terraform_remote_state.vpc.outputs.private_app_subnet_ids_list, 0, 2
      )

      # Always ON_DEMAND — system nodes must never be interrupted
      capacity_type = "ON_DEMAND"

      # Taint: only pods that tolerate CriticalAddonsOnly land here.
      # CoreDNS, kube-proxy, and Karpenter pods all carry this toleration.
      # Your 30 Java services will never be scheduled here.
      taints = {
        dedicated = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }

      labels = {
        role = "system"
      }

      # Attach your existing nodes SG (carries karpenter.sh/discovery tag)
      vpc_security_group_ids = [
        data.terraform_remote_state.sg.outputs.eks_nodes_sg_id
      ]

      # 50 GB encrypted gp3 root volume
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

      tags = {
        role                     = "system"
        "karpenter.sh/discovery" = "${var.project}-${var.environment}-eks"
      }
    }
  }

  # Tag the cluster so Karpenter can discover it
  tags = merge(var.tags, {
    "karpenter.sh/discovery" = "${var.project}-${var.environment}-eks"
  })
}
