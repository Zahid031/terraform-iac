# Module: ec2-bastion

Creates a private bastion EC2 instance accessible only via AWS SSM Session Manager.
No public IP, no key pair, no open SSH port required.

## Resources created

| Resource                   | Purpose                              |
|----------------------------|--------------------------------------|
| aws_instance               | AL2023 bastion, private subnet       |
| aws_iam_role               | EC2 instance role                    |
| aws_iam_instance_profile   | Attached to instance                 |

## IAM permissions on the bastion role

| Policy                          | Why                                   |
|---------------------------------|---------------------------------------|
| AmazonSSMManagedInstanceCore    | SSM Session Manager access            |
| AmazonEC2ContainerRegistryReadOnly | Pull images for debugging          |
| inline: eks:DescribeCluster     | `aws eks update-kubeconfig` works     |

## Accessing the bastion

```bash
# Get the command from Terraform output
terraform -chdir=environments/prod/ec2-bastion output ssm_connect_command

# Or directly
aws ssm start-session --target <instance-id> --region ap-southeast-1

# Once inside, configure kubectl
aws eks update-kubeconfig --name rideshare-prod-eks --region ap-southeast-1
kubectl get nodes
```

## IMDSv2

`http_tokens = required` enforces IMDSv2 on the instance metadata endpoint.
This prevents SSRF-based metadata credential theft.

## Inputs

| Variable         | Required | Description                                        |
|------------------|----------|----------------------------------------------------|
| `name`           | yes      | Resource name prefix                               |
| `subnet_id`      | yes      | Private app subnet — from vpc remote state         |
| `bastion_sg_id`  | yes      | From security-groups remote state                  |
| `instance_type`  | no       | Default `t3.small`                                 |
| `kubectl_version`| no       | Default `1.32.0` — keep in sync with cluster       |
| `tags`           | no       | Merged onto all resources                          |
