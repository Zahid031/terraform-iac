# environments/prod/eks

Entry point for the EKS layer. Reads VPC + security-groups remote state,
calls `modules/eks`, exposes cluster outputs for the karpenter layer.

## Files

| File              | Purpose                              |
|-------------------|--------------------------------------|
| backend.tf        | S3 state — eks/terraform.tfstate     |
| provider.tf       | AWS + TLS provider                   |
| main.tf           | Remote state reads + module + outputs|
| variables.tf      | Input variable declarations          |
| terraform.tfvars  | Prod values including pinned addons  |

## Deploy

```bash
cd environments/prod/eks
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Depends on

- `environments/prod/vpc` state (subnets)
- `environments/prod/security-groups` state (cluster SG)

## Consumed by

- `environments/prod/karpenter` — needs OIDC, node role, instance profile

## After apply — verify cluster

```bash
# From the bastion (SSM)
aws eks update-kubeconfig --name rideshare-prod-eks --region ap-southeast-1
kubectl get nodes
kubectl get pods -A
```
