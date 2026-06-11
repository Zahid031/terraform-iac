# rideshare-infra — Official Module Edition

## What changed from the custom-module version

| Layer | Before | After |
|---|---|---|
| `modules/eks/` | Custom hand-rolled resources | **Deleted** — replaced by `terraform-aws-modules/eks/aws ~> 20.0` called directly in the environment |
| `modules/karpenter/` | Custom hand-rolled resources | **Deleted** — replaced by `terraform-aws-modules/eks/aws//modules/karpenter ~> 20.0` |
| `modules/security-groups/` | Custom (kept) | **Unchanged** |
| `modules/ec2-bastion/` | Custom (kept) | **Unchanged** |
| `environments/prod/eks/` | Called custom module | Calls official EKS module |
| `environments/prod/karpenter/` | Called custom module | Calls official Karpenter sub-module; provider.tf now includes helm + kubernetes providers |

## Why official modules

- **Actively maintained** by the `terraform-aws-modules` org — tracks upstream EKS API changes, Karpenter CRD changes, IAM policy updates automatically.
- **Pod Identity support** — the official Karpenter sub-module supports both IRSA and the newer EKS Pod Identity authentication (toggle `enable_pod_identity`).
- **Tested at scale** — used by thousands of production clusters.

## Apply order (unchanged)

```
1. vpc/           (external or pre-existing)
2. security-groups/
3. eks/
4. karpenter/
5. ec2-bastion/
```

## Migrating existing state

If you have existing resources managed by the old custom modules, you must `terraform state mv` them to the new module addresses before running `apply`, otherwise Terraform will destroy and recreate them. Key mappings:

```bash
# EKS cluster
terraform state mv 'module.eks.aws_eks_cluster.this' 'module.eks.aws_eks_cluster.this[0]'

# Node IAM role
terraform state mv 'module.eks.aws_iam_role.node' 'module.eks.aws_iam_role.workers[0]'

# Karpenter controller role
terraform state mv 'module.karpenter.aws_iam_role.controller' 'module.karpenter.aws_iam_role.this[0]'

# SQS queue
terraform state mv 'module.karpenter.aws_sqs_queue.interruption' 'module.karpenter.aws_sqs_queue.this[0]'
```

Run `terraform plan` after each move and verify zero destructive changes before `apply`.
