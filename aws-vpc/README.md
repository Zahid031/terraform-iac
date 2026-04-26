# Terraform VPC — ap-southeast-1

Production-ready VPC module for AWS `ap-southeast-1` with public/private subnets, NAT Gateways, and reusable Security Groups.

---

## Architecture

```
VPC: 10.0.0.0/16
│
├── Public Subnets (IGW route)
│   ├── 10.0.1.0/24  →  ap-southeast-1a  [NAT GW 1]
│   ├── 10.0.2.0/24  →  ap-southeast-1b  [NAT GW 2]
│   └── 10.0.3.0/24  →  ap-southeast-1c  [NAT GW 3]
│
└── Private Subnets (NAT GW route)
    ├── 10.0.11.0/24  →  ap-southeast-1a
    ├── 10.0.12.0/24  →  ap-southeast-1b
    └── 10.0.13.0/24  →  ap-southeast-1c

Security Groups
├── sg_alb  →  80, 443 from 0.0.0.0/0
├── sg_app  →  8080 from VPC CIDR
└── sg_rds  →  5432 from private subnets
```

---

## Project Structure

```
terraform-vpc/
├── backend.tf          # Remote state (S3 — uncomment to enable)
├── provider.tf         # AWS provider + version constraints
├── main.tf             # Module calls only — no direct resources
├── variables.tf        # All input variables with descriptions
├── outputs.tf          # Root-level outputs
├── terraform.tfvars    # Your actual values
│
└── modules/
    ├── vpc/
    │   ├── main.tf     # VPC + Internet Gateway
    │   ├── subnets.tf  # Public + Private subnets
    │   ├── nat.tf      # Elastic IPs + NAT Gateways
    │   ├── routing.tf  # Route tables + associations
    │   ├── locals.tf   # Shared local values
    │   ├── variables.tf
    │   └── outputs.tf
    │
    └── security_group/
        ├── main.tf     # SG with dynamic ingress/egress rules
        ├── variables.tf
        └── outputs.tf
```

---

## Usage

### 1. Configure your values

Edit `terraform.tfvars`:

```hcl
project_name = "myapp"
environment  = "dev"
```

### 2. (Optional) Enable remote state

Uncomment and configure the `backend "s3"` block in `backend.tf`.

### 3. Deploy

```bash
terraform init
terraform validate
terraform fmt -recursive
terraform plan
terraform apply
```

### 4. Tear down

```bash
terraform destroy
```

---

## Key Variables

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `ap-southeast-1` | AWS region |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `enable_nat_gateway` | `true` | Create NAT Gateways |
| `single_nat_gateway` | `false` | One NAT for all AZs (cost saving) |

> **Tip:** Set `single_nat_gateway = true` in `dev`/`staging` to reduce costs. Use `false` in `prod` for high availability.

---

## Adding a New Security Group

In `main.tf`, add another module block:

```hcl
module "sg_custom" {
  source         = "./modules/security_group"
  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.vpc.vpc_id
  sg_name        = "custom"
  sg_description = "My custom security group"

  ingress_rules = [
    {
      description = "Custom port"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  ]
}
```
