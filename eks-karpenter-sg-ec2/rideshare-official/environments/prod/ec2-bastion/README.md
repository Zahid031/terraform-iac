# environments/prod/ec2-bastion

Entry point for the bastion layer. Creates a private EC2 instance
accessible only via AWS SSM Session Manager — no public IP, no SSH key.

## Files

| File              | Purpose                                    |
|-------------------|--------------------------------------------|
| backend.tf        | S3 state — ec2-bastion/terraform.tfstate   |
| provider.tf       | AWS provider                               |
| main.tf           | Remote state reads + module + outputs      |
| variables.tf      | Input variable declarations                |
| terraform.tfvars  | Prod values                                |

## Deploy

```bash
cd environments/prod/ec2-bastion
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Connect to bastion

```bash
# Get the SSM command from output
terraform output ssm_connect_command

# Runs as:
aws ssm start-session --target i-xxxxxxxxxxxxxxxxx --region ap-southeast-1

# Once inside, configure kubectl
aws eks update-kubeconfig --name rideshare-prod-eks --region ap-southeast-1
kubectl get nodes
```

## Depends on

- `environments/prod/vpc` state (private app subnet ID)
- `environments/prod/security-groups` state (bastion SG ID)

## Independent of

- `environments/prod/eks` — can be deployed before or after EKS
- `environments/prod/karpenter` — no dependency
