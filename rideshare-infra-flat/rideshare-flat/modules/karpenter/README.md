# Module: karpenter

Creates the AWS-side infrastructure for Karpenter:
- Controller IAM role with IRSA trust policy
- Scoped IAM policy (EC2, SQS, IAM PassRole, EKS Describe)
- SQS interruption queue (spot + health events)
- EventBridge rules routing interruption events to SQS

Helm install and Kubernetes manifests (EC2NodeClass, NodePool) live in
`environments/prod/karpenter/` — not in this module.

## Resources created

| Resource                       | Purpose                                          |
|--------------------------------|--------------------------------------------------|
| aws_iam_role (controller)      | IRSA role for Karpenter controller pod           |
| aws_iam_policy (controller)    | Scoped EC2/SQS/IAM permissions                   |
| aws_sqs_queue (interruption)   | Receives spot/health events for graceful drain   |
| aws_cloudwatch_event_rule x3   | Spot interruption, state change, health events   |

## IAM policy scope

The policy uses resource-level conditions where possible:
- Terminate/delete only resources tagged `karpenter.sh/nodepool = *`
- PassRole scoped to the specific node role ARN
- GetInstanceProfile scoped to the specific instance profile ARN

## Inputs

| Variable                   | Required | Description                               |
|----------------------------|----------|-------------------------------------------|
| `cluster_name`             | yes      | From eks remote state                     |
| `oidc_provider_arn`        | yes      | From eks remote state                     |
| `oidc_issuer_url`          | yes      | From eks remote state                     |
| `node_role_arn`            | yes      | From eks remote state                     |
| `node_instance_profile_arn`| yes      | From eks remote state                     |
| `tags`                     | no       | Merged onto all resources                 |

## Outputs

| Output                    | Where to use                                      |
|---------------------------|---------------------------------------------------|
| `controller_role_arn`     | karpenter-helm-values.yaml serviceAccount.annotations |
| `interruption_queue_name` | karpenter-helm-values.yaml settings.interruptionQueue |
