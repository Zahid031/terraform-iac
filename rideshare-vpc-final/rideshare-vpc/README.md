# rideshare-vpc

Three-tier VPC module — public / private-app / private-data — with 4 route tables
(1 public shared + 1 private per AZ), optional NAT HA, VPC endpoints, and flow logs.

## Structure

```
modules/vpc/          # reusable module — edit this
  main.tf             # all resources
  variables.tf        # every toggle lives here
  outputs.tf

environments/
  prod/               # 3× NAT GW, all endpoints, flow logs 90d
  staging/            # 1× NAT GW, ECR+STS endpoints, flow logs 14d
  dev/                # 1× NAT GW, S3 endpoint only, flow logs off
```

## Route table layout

```
1 public RT  → IGW          (all 3 public subnets)
RT-private-1a → NAT-GW-1a  (app-1a + data-1a)
RT-private-1b → NAT-GW-1b  (app-1b + data-1b)
RT-private-1c → NAT-GW-1c  (app-1c + data-1c)
```

App and data subnets share the same per-AZ private RT.
Security groups and NACLs enforce tier isolation at the network level.

## Key toggles (variables.tf)

| Variable | prod | staging | dev |
|---|---|---|---|
| `single_nat_gateway` | false | true | true |
| `enable_ecr_endpoints` | true | true | false |
| `enable_sts_endpoint` | true | true | false |
| `enable_ssm_endpoints` | true | false | false |
| `enable_flow_logs` | true | true | false |
| `flow_logs_retention_days` | 90 | 14 | 7 |

## Usage

```bash
cd environments/prod
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Subnet layout (prod)

| Tier | AZ-1a | AZ-1b | AZ-1c |
|---|---|---|---|
| Public | 10.0.0.0/24 | 10.0.1.0/24 | 10.0.2.0/24 |
| App | 10.0.8.0/22 | 10.0.16.0/22 | 10.0.24.0/22 |
| Data | 10.0.32.0/22 | 10.0.40.0/22 | 10.0.48.0/22 |

Staging uses 10.1.x.x, dev uses 10.2.x.x — no CIDR overlap.
