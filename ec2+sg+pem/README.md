# EC2 with PEM Key — Terraform Project

Provisions an EC2 instance in the **default VPC and subnet** with a generated PEM key and a locked-down SSH security group.

## Project Structure

```
ec2-project/
├── provider.tf       # Terraform & provider version constraints
├── variables.tf      # All input variable declarations
├── terraform.tfvars  # Your variable values (edit before applying)
├── locals.tf         # Computed local values (common tags)
├── data.tf           # Data sources: default VPC & subnets
├── main.tf           # Core resources: key pair, SG, EC2
├── outputs.tf        # Outputs: IP, SSH command, IDs
└── README.md
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured (`aws configure`) or `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` env vars set
- A default VPC in your target region (all AWS accounts have one by default)

## Quick Start

### 1. Find your public IP
```bash
curl https://checkip.amazonaws.com
# e.g. 203.0.113.5  →  use 203.0.113.5/32 in terraform.tfvars
```

### 2. Find the correct AMI for your region
- Amazon Linux 2 AMIs differ per region
- Find yours at: https://us-east-1.console.aws.amazon.com/ec2/home#AMICatalog

### 3. Update terraform.tfvars
```hcl
aws_region    = "us-east-1"
instance_name = "my-web-server"
instance_type = "t3.micro"
ami_id        = "ami-xxxxxxxxxxxxxxxxx"  # your region's AMI
key_name      = "my-ec2-key"
my_ip         = "203.0.113.5/32"         # your IP from step 1
project       = "my-project"
environment   = "dev"
```

### 4. Deploy
```bash
terraform init
terraform plan
terraform apply
```

### 5. SSH into your instance
After apply, Terraform prints an `ssh_command` output. Copy-paste it:
```bash
ssh -i my-ec2-key.pem ec2-user@<PUBLIC_IP>
```

> **Note:** Default usernames by OS:
> - Amazon Linux / Amazon Linux 2 → `ec2-user`
> - Ubuntu → `ubuntu`
> - RHEL → `ec2-user`
> - Debian → `admin`

### 6. Destroy when done
```bash
terraform destroy
```

## Security Notes

- ⚠️  The `.pem` file is saved locally **and** stored in `terraform.tfstate` — never commit either to Git.
- Add `*.pem` and `terraform.tfstate` to `.gitignore`.
- Always restrict `my_ip` to your specific IP (`x.x.x.x/32`), not `0.0.0.0/0`.

## .gitignore (recommended)

```
*.pem
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl
terraform.tfvars
```
