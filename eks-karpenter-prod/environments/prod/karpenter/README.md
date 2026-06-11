# environments/prod/karpenter

Karpenter AWS infrastructure using the official
`terraform-aws-modules/eks/aws//modules/karpenter ~> 20.0` submodule.
Reads EKS outputs from remote state — no EKS resources created here.

## Files

| File                       | Purpose                                              |
|----------------------------|------------------------------------------------------|
| `backend.tf`               | S3 remote state — `karpenter/terraform.tfstate`      |
| `provider.tf`              | AWS provider + version constraints                   |
| `variables.tf`             | Input variable declarations                          |
| `terraform.tfvars`         | Prod values                                          |
| `main.tf`                  | Remote state read + Karpenter module call            |
| `outputs.tf`               | IAM role ARN, queue name (used in Helm + manifests)  |
| `karpenter-helm-values.yaml` | Helm chart values (fill 2 placeholders after apply)|
| `node-class.yaml`          | EC2NodeClass — subnet + SG discovery via tags        |
| `node-pool.yaml`           | NodePool — spot-first, c/m/r, gen4+, 3 AZs          |

## What gets created by Terraform

| Resource                        | Details                                         |
|---------------------------------|-------------------------------------------------|
| Karpenter controller IAM role   | IRSA, scoped to karpenter service account       |
| Karpenter controller IAM policy | EC2, SQS, PassRole, EKS Describe                |
| SQS interruption queue          | Spot + health + state-change events, 5min TTL   |
| EventBridge rules (x3)          | Spot interruption, instance state, health events|

## Full deploy sequence

```bash
# Step 1 — Terraform
cd environments/prod/karpenter
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Step 2 — Get values for Helm
terraform output -raw controller_role_arn
terraform output -raw interruption_queue_name

# Step 3 — Paste both values into karpenter-helm-values.yaml, then install
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version 1.3.3 \
  --namespace karpenter --create-namespace \
  -f karpenter-helm-values.yaml

# Step 4 — Verify Karpenter pods are running on system nodes
kubectl get pods -n karpenter -o wide

# Step 5 — Apply node resources
kubectl apply -f node-class.yaml
kubectl apply -f node-pool.yaml

# Step 6 — Verify
kubectl get nodeclasses
kubectl get nodepools
```

## Tag requirements

Karpenter discovers subnets and SGs via tags. Verify these exist:

```bash
# Subnets must have:
karpenter.sh/discovery = rideshare-prod-eks

# eks-nodes SG must have:
karpenter.sh/discovery = rideshare-prod-eks
```

The SG tag is set in `modules/security-groups/main.tf`.
The subnet tag must be set in your VPC module on the private-app subnets.

## Depends on

- `environments/prod/eks` — cluster name, OIDC ARN, node role ARN
