# environments/prod/eks/main.tf

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "vpc/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

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
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # v21 renames: cluster_name → name
  name               = "${var.project}-${var.environment}-eks"
  kubernetes_version = var.kubernetes_version

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_app_subnet_ids_list

  # v21 renames: cluster_endpoint_public_access → endpoint_public_access
  endpoint_public_access  = true
  endpoint_private_access = false

  # v21 renames: create_cluster_security_group → create_security_group
  create_security_group = false
  security_group_id     = data.terraform_remote_state.sg.outputs.eks_cluster_sg_id

  create_node_security_group = false
  node_security_group_id     = data.terraform_remote_state.sg.outputs.eks_nodes_sg_id

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  create_cloudwatch_log_group = false   # ← add this line


  # v21 renames: cluster_enabled_log_types → enabled_log_types
  # enabled_log_types = [
  #   "api", "audit", "authenticator", "controllerManager", "scheduler"
  # ]

  # v21 renames: cluster_addons → addons
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
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  # eks_managed_node_groups — unchanged in v21
  eks_managed_node_groups = {
    system = {
      instance_types = ["t3.small"]
      min_size       = 2
      max_size       = 2
      desired_size   = 2

      subnet_ids    = slice(data.terraform_remote_state.vpc.outputs.private_app_subnet_ids_list, 0, 2)
      capacity_type = "ON_DEMAND"

      taints = {
        dedicated = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }

      labels = { role = "system" }

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

      iam_role_additional_policies = {
        AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }

      tags = {
        role                     = "system"
        "karpenter.sh/discovery" = "${var.project}-${var.environment}-eks"
      }
    }
  }

  tags = merge(var.tags, {
    "karpenter.sh/discovery" = "${var.project}-${var.environment}-eks"
  })
}