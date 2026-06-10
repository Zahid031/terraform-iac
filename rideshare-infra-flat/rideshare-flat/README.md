# Rideshare Infrastructure — Flat Layout

## Structure

```
rideshare-infra/
├── modules/                         ← reusable modules, no AWS state
│   ├── security-groups/             ← all SGs: cluster, nodes, ALB, data, bastion
│   ├── eks/                         ← cluster, IAM roles, OIDC, add-ons
│   ├── karpenter/                   ← controller IAM, SQS queue, EventBridge
│   └── ec2-bastion/                 ← private EC2, SSM-only access
└── environments/
    └── prod/
        ├── vpc/                     ← existing VPC, DO NOT re-apply
        ├── security-groups/         ← reads vpc state, calls module
        ├── eks/                     ← reads vpc+sg state, calls module
        ├── karpenter/               ← reads eks state, calls module
        └── ec2-bastion/             ← reads vpc+sg state, calls module
```

## Why this layout

modules/ contains logic. Each module receives everything as variables and
knows nothing about remote state. environments/prod/ contains wiring —
each folder is 4-5 thin files that read remote state and pass values into
the module. Adding staging = add environments/staging/<layer>/ pointing at
the same modules with no module code changes.

## State file map (bucket: rideshare-terraform-state-prod, ap-southeast-1)

| Layer           | S3 Key                            | Order |
|-----------------|-----------------------------------|-------|
| vpc             | vpc/terraform.tfstate             | 1 — already done, never re-apply |
| security-groups | security-groups/terraform.tfstate | 2 |
| eks             | eks/terraform.tfstate             | 3 |
| karpenter       | karpenter/terraform.tfstate       | 4 |
| ec2-bastion     | ec2-bastion/terraform.tfstate     | 5 (any time after sg) |

## Deploy (same command for every layer)

```bash
cd environments/prod/<layer>
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

## Karpenter post-Terraform steps

```bash
terraform -chdir=environments/prod/karpenter output controller_role_arn
terraform -chdir=environments/prod/karpenter output interruption_queue_name
# Paste both into environments/prod/karpenter/karpenter-helm-values.yaml, then:

helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version 1.3.3 --namespace karpenter --create-namespace \
  -f environments/prod/karpenter/karpenter-helm-values.yaml

kubectl apply -f environments/prod/karpenter/node-class.yaml
kubectl apply -f environments/prod/karpenter/node-pool.yaml
```

## Bastion access

```bash
terraform -chdir=environments/prod/ec2-bastion output ssm_connect_command
# Inside bastion:
aws eks update-kubeconfig --name rideshare-prod-eks --region ap-southeast-1
kubectl get nodes
```
