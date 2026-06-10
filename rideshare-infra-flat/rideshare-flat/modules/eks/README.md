# Module: eks

Creates the EKS cluster, IAM roles, OIDC provider, and core add-ons.
Does not manage networking or security groups — those are passed in as variables.

## Resources created

| Resource                        | Purpose                                          |
|---------------------------------|--------------------------------------------------|
| aws_eks_cluster                 | Private EKS cluster (no public endpoint)         |
| aws_iam_role (cluster)          | Cluster service role                             |
| aws_iam_role (node)             | Node role — used by all Karpenter-launched nodes |
| aws_iam_instance_profile (node) | Required for EC2 launch                          |
| aws_iam_openid_connect_provider | OIDC — enables IRSA and Karpenter controller role|
| aws_eks_addon (vpc-cni)         | VPC CNI networking                               |
| aws_eks_addon (coredns)         | Cluster DNS                                      |
| aws_eks_addon (kube-proxy)      | Node network proxy                               |
| aws_eks_addon (pod-identity)    | EKS Pod Identity agent                           |

## Private cluster

`endpoint_public_access = false` — the API server is not reachable from
the internet. All kubectl access must go through the bastion via SSM:

```bash
aws ssm start-session --target <bastion-instance-id> --region ap-southeast-1
aws eks update-kubeconfig --name rideshare-prod-eks --region ap-southeast-1
```

## Inputs

| Variable                 | Required | Description                              |
|--------------------------|----------|------------------------------------------|
| `cluster_name`           | yes      | e.g. `rideshare-prod-eks`                |
| `kubernetes_version`     | no       | Default `1.32`                           |
| `private_app_subnet_ids` | yes      | From vpc remote state                    |
| `eks_cluster_sg_id`      | yes      | From security-groups remote state        |
| `vpc_cni_version`        | no       | Pin addon versions for stability         |
| `coredns_version`        | no       | Pin addon versions for stability         |
| `kube_proxy_version`     | no       | Pin addon versions for stability         |
| `tags`                   | no       | Merged onto all resources                |

## Key outputs consumed downstream

| Output                    | Consumed by              |
|---------------------------|--------------------------|
| `cluster_name`            | karpenter module         |
| `cluster_oidc_issuer`     | karpenter module (IRSA)  |
| `oidc_provider_arn`       | karpenter module (IRSA)  |
| `node_role_arn`           | karpenter module         |
| `node_role_name`          | EC2NodeClass spec.role   |
| `node_instance_profile_arn` | karpenter module       |
