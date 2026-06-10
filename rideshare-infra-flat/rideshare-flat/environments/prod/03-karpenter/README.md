# environments/prod/karpenter

Entry point for the karpenter layer. Creates AWS-side infrastructure
(IAM role, SQS queue, EventBridge rules). Helm install and Kubernetes
manifests are applied manually after Terraform.

## Files

| File                        | Purpose                                        |
|-----------------------------|------------------------------------------------|
| backend.tf                  | S3 state — karpenter/terraform.tfstate         |
| provider.tf                 | AWS provider                                   |
| main.tf                     | Remote state reads + module + outputs          |
| variables.tf                | Input variable declarations                    |
| terraform.tfvars            | Prod values                                    |
| karpenter-helm-values.yaml  | Helm chart values (fill in ARN after apply)    |
| node-class.yaml             | EC2NodeClass — subnet + SG discovery via tags  |
| node-pool.yaml              | NodePool — spot-first, c/m/r, gen4+            |

## Full deploy sequence

```bash
# Step 1 — Terraform (AWS resources)
cd environments/prod/karpenter
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Step 2 — Fill Helm values
terraform output controller_role_arn    # paste into karpenter-helm-values.yaml
terraform output interruption_queue_name # paste into karpenter-helm-values.yaml

# Step 3 — Install Karpenter via Helm (run from bastion or CI with kubeconfig)
helm upgrade --install karpenter oci://public.ecr.aws/karpenter/karpenter \
  --version 1.3.3 \
  --namespace karpenter --create-namespace \
  -f karpenter-helm-values.yaml

# Step 4 — Apply node resources
kubectl apply -f node-class.yaml
kubectl apply -f node-pool.yaml

# Verify
kubectl get nodeclasses
kubectl get nodepools
kubectl get nodes
```

## Depends on

- `environments/prod/eks` state (OIDC, node role, instance profile)
