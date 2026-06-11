# environments/prod/security-groups

Entry point for the security-groups layer. Thin wrapper that:
1. Reads VPC outputs from remote state (read-only)
2. Calls `modules/security-groups` with the VPC IDs
3. Exposes SG IDs as outputs for downstream layers

## Files

| File              | Purpose                                      |
|-------------------|----------------------------------------------|
| backend.tf        | S3 state — security-groups/terraform.tfstate |
| provider.tf       | AWS provider, version constraints            |
| main.tf           | Remote state reads + module call + outputs   |
| variables.tf      | Input variable declarations                  |
| terraform.tfvars  | Prod values                                  |

## Deploy

```bash
cd environments/prod/security-groups
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Depends on

- `environments/prod/vpc` state must exist (already deployed)

## Consumed by

- `environments/prod/eks`      — needs eks_cluster_sg_id
- `environments/prod/ec2-bastion` — needs bastion_sg_id
