###############################################################################
# environments/prod/eks/main.tf
# Uses the official terraform-aws-modules/eks/aws module (production-grade).
# The module creates: cluster, managed node groups (none here — Karpenter only),
# OIDC provider, add-ons, node IAM role/instance profile.
###############################################################################

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

###############################################################################
# Official EKS module
# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
###############################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.project}-${var.environment}-eks"
  cluster_version = var.kubernetes_version

  # Private cluster — access via bastion / SSM only
  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids_list

  # Attach the cluster SG from the security-groups layer
  cluster_additional_security_group_ids = [
    data.terraform_remote_state.sg.outputs.eks_cluster_sg_id,
  ]

  # Enable all control-plane log types
  cluster_enabled_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  # Authentication — API + ConfigMap (same as your original)
  authentication_mode                         = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions    = true

  # ── EKS Add-ons ─────────────────────────────────────────────────────────────
  cluster_addons = {
    vpc-cni = {
      addon_version               = var.vpc_cni_version
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      addon_version               = var.coredns_version
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      addon_version               = var.kube_proxy_version
      resolve_conflicts_on_update = "OVERWRITE"
    }
    eks-pod-identity-agent = {}
  }

  # No managed node groups — Karpenter provisions all nodes
  # eks_managed_node_groups = {}
  eks_managed_node_groups = {
    system = {
      instance_types = ["t3.medium"]   # 2 vCPU, 4GB — enough for system pods
      min_size       = 2
      max_size       = 2
      desired_size   = 2

      # Spread across 2 AZs for HA
      subnet_ids = slice(
        data.terraform_remote_state.vpc.outputs.private_app_subnet_ids_list, 0, 2
      )

      # Taint so ONLY system pods land here — Karpenter won't schedule app pods
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

      # These nodes are always on — on-demand only, never spot
      capacity_type = "ON_DEMAND"

      # Node group uses the same node SG from your security-groups layer
      vpc_security_group_ids = [
        data.terraform_remote_state.sg.outputs.eks_nodes_sg_id
      ]

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
        role = "system"
      }
    }
    

  # The module creates an IAM role for nodes; Karpenter uses this role
  # to launch new EC2 instances.
  create_iam_role = true  # cluster role

  # Node IAM role — Karpenter attaches this to every node it launches
  node_security_group_additional_rules = {
    # Allow node-to-node (already covered by the nodes SG, belt-and-suspenders)
    ingress_self_all = {
      description = "Node-to-node all ports"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  tags = merge(var.tags, {
    # Tag required so the karpenter sub-module can find the cluster
    "karpenter.sh/discovery" = "${var.project}-${var.environment}-eks"
  })
}

# ── Outputs consumed by the karpenter layer ──────────────────────────────────
output "cluster_name"              { value = module.eks.cluster_name }
output "cluster_endpoint"          { value = module.eks.cluster_endpoint }
output "cluster_ca_cert"           {
  value     = module.eks.cluster_certificate_authority_data
  sensitive = true
}
output "cluster_oidc_issuer"       { value = module.eks.cluster_oidc_issuer_url }
output "oidc_provider_arn"         { value = module.eks.oidc_provider_arn }
output "node_role_arn"             { value = module.eks.eks_managed_node_groups_iam_role_arns == {} ? module.eks.cluster_iam_role_arn : module.eks.cluster_iam_role_arn }
output "node_role_name"            { value = module.eks.cluster_iam_role_name }
output "node_instance_profile_arn" { value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/${module.eks.cluster_name}-node" }

data "aws_caller_identity" "current" {}
