# Terraform AWS Instance Deployment

This project contains Terraform configurations to deploy AWS EC2 instances.

## Files

- **`createinstance.tf`**: This file defines a single EC2 instance with a specific AMI and instance type.

- **`multiinstance.tf`**: This file defines the creation of multiple EC2 instances using the `count` meta-argument. It also adds tags to each instance with a unique name.

- **`ubuntu.tf`**: This file contains a resource block to create an EC2 instance named "ubuntu2". It also contains commented-out code that shows how to use a data source to find the latest Ubuntu AMI.

- **`providers/main.tf`**: This file configures the AWS provider with the `us-east-1` region.

- **`providers/terraform.tf`**: This file specifies the required Terraform providers, in this case, the AWS provider from HashiCorp.

## How to Use

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Plan the deployment:**
   ```bash
   terraform plan
   ```

3. **Apply the changes:**
   ```bash
   terraform apply
   ```

4. **Destroy the resources:**
   ```bash
   terraform destroy
   ```
