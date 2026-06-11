# environments/prod/eks

Production EKS cluster using the official `terraform-aws-modules/eks/aws ~> 20.0` registry module.
Wires your existing VPC and security-groups layers via remote state — no VPC resources are created or modified here.

## Files

| File               | Purpose                                                  |
|--------------------|----------------------------------------------------------|
| `backend.tf`       | S3 remote state — `eks/terraform.tfstate`                |
| `provider.tf`      | AWS provider + version constraints                       |
| `variables.tf`     | All input variable declarations with types and defaults  |
| `terraform.tfvars` | Prod values (versions, tags)                             |
| `main.tf`          | Remote state reads + EKS registry module call            |
| `outputs.tf`       | All outputs consumed by the karpenter layer              |

## What gets created

| Resource                  | Details                                               |
|---------------------------|-------------------------------------------------------|
| EKS cluster               | Private only, no public endpoint                      |
| System node group         | 2x t3.medium, ON_DEMAND, tainted CriticalAddonsOnly   |
| EKS add-ons               | vpc-cni, coredns, kube-proxy, eks-pod-identity-agent  |
| OIDC provider             | Used by Karpenter IRSA in the next layer              |
| Node IAM role             | Shared by system nodes and Karpenter-launched nodes   |

## Security groups

`create_cluster_security_group = false` and `create_node_security_group = false`
tells the registry module to use your existing SGs instead of creating new ones.
All rules remain managed in the `security-groups` layer.

## System node group — why it exists

Karpenter cannot provision its own nodes (chicken-and-egg).
These 2 nodes are the permanent home for:
- coredns
- kube-proxy
- karpenter controller pods
- Any other critical add-ons

The `CriticalAddonsOnly=true:NoSchedule` taint ensures your 30 Java
microservices never land here. Karpenter provisions all app nodes dynamically.

## Deploy

```bash
cd environments/prod/eks
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Verify

```bash
# From inside bastion (SSM)
aws eks update-kubeconfig --name rideshare-prod-eks --region ap-southeast-1
kubectl get nodes
kubectl get pods -A
```

## Outputs consumed by karpenter layer

| Output                    | Used for                              |
|---------------------------|---------------------------------------|
| `cluster_name`            | Karpenter module cluster_name         |
| `cluster_oidc_issuer`     | Karpenter IRSA trust policy           |
| `oidc_provider_arn`       | Karpenter IRSA trust policy           |
| `node_role_arn`           | Karpenter PassRole permission         |
| `node_role_name`          | EC2NodeClass spec.role                |
| `node_instance_profile_arn` | Karpenter instance profile          |

## Depends on

- `environments/prod/vpc` — subnets
- `environments/prod/security-groups` — cluster SG + node SG
