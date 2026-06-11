# Module: security-groups

Creates all security groups for the rideshare platform. This module is
VPC-agnostic — it receives `vpc_id` and `vpc_cidr` as variables so it
can be reused across environments without any code changes.

## Resources created

| Resource         | Name suffix        | Purpose                                       |
|------------------|--------------------|-----------------------------------------------|
| aws_security_group | sg-eks-cluster   | EKS control plane <-> nodes (port 443)        |
| aws_security_group | sg-eks-nodes     | Worker nodes, tagged for Karpenter discovery  |
| aws_security_group | sg-alb           | External ALB, HTTP/HTTPS from 0.0.0.0/0       |
| aws_security_group | sg-data-plane    | Postgres/Redis/Kafka/ScyllaDB from nodes only |
| aws_security_group | sg-bastion       | SSH from allowed CIDRs (SSM is preferred)     |

## Karpenter tag wiring

`sg-eks-nodes` is tagged:
- `karpenter.sh/discovery = <cluster_name>`
- `kubernetes.io/cluster/<cluster_name> = owned`

Karpenter's EC2NodeClass uses `securityGroupSelectorTerms` to discover
this SG automatically. No hardcoded SG IDs needed in node-class.yaml.

## Inputs

| Variable               | Required | Description                                   |
|------------------------|----------|-----------------------------------------------|
| `name`                 | yes      | Resource name prefix e.g. `rideshare-prod`    |
| `vpc_id`               | yes      | From vpc remote state output                  |
| `vpc_cidr`             | yes      | From vpc remote state output                  |
| `cluster_name`         | yes      | EKS cluster name for SG tag                   |
| `bastion_allowed_cidrs`| no       | SSH CIDRs, default [] = SSM only              |
| `tags`                 | no       | Merged onto all resources                     |

## Outputs consumed by other layers

| Output               | Consumed by              |
|----------------------|--------------------------|
| `eks_cluster_sg_id`  | environments/prod/eks    |
| `bastion_sg_id`      | environments/prod/ec2-bastion |
| `alb_sg_id`          | ALB controller Helm values|
| `data_plane_sg_id`   | data-plane layer (future) |
