terraform {
  required_version = ">= 1.9"
  required_providers {
    aws        = { source = "hashicorp/aws",        version = "~> 5.0" }
    helm       = { source = "hashicorp/helm",       version = "~> 2.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.0" }
  }
}

provider "aws" {
  region = var.region
  default_tags { tags = var.tags }
}

# Helm + Kubernetes providers — needed to install the Karpenter controller chart
# and apply NodePool / EC2NodeClass manifests into the cluster.
# They read the cluster endpoint/CA from EKS remote state so this layer stays
# self-contained and doesn't need a pre-configured kubeconfig.
data "terraform_remote_state" "eks_provider" {
  backend = "s3"
  config = {
    bucket  = "rideshare-terraform-state-prod"
    key     = "eks/terraform.tfstate"
    region  = "ap-southeast-1"
    encrypt = true
  }
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.eks_provider.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_provider.outputs.cluster_ca_cert)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks_provider.outputs.cluster_name]
    }
  }
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.eks_provider.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.eks_provider.outputs.cluster_ca_cert)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.eks_provider.outputs.cluster_name]
  }
}
