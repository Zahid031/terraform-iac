# Terraform Variables — Complete Guide

> A hands-on reference for understanding, using, and practicing Terraform variables from beginner to advanced.

---

## Table of Contents

1. [What Are Variables?](#1-what-are-variables)
2. [Declaring Input Variables](#2-declaring-input-variables)
3. [Variable Types](#3-variable-types)
4. [Default Values](#4-default-values)
5. [Validation Rules](#5-validation-rules)
6. [Sensitive Variables](#6-sensitive-variables)
7. [Assigning Variable Values](#7-assigning-variable-values)
8. [Output Variables](#8-output-variables)
9. [Local Values](#9-local-values)
10. [Variable Precedence](#10-variable-precedence)
11. [Complex Types in Practice](#11-complex-types-in-practice)
12. [Practice Exercises](#12-practice-exercises)
13. [Cheat Sheet](#13-cheat-sheet)

---

## 1. What Are Variables?

Variables in Terraform allow you to **parameterize your configurations** so they are reusable, flexible, and don't contain hardcoded values.

There are three kinds of named values in Terraform:

| Kind | Keyword | Purpose |
|------|---------|---------|
| Input Variables | `variable` | Accept values from outside the module |
| Output Values | `output` | Expose values from a module or root config |
| Local Values | `locals` | Compute intermediate values within a module |

Think of input variables like function arguments, outputs like return values, and locals like local variables inside a function.

---

## 2. Declaring Input Variables

Input variables are declared using the `variable` block in any `.tf` file (by convention, usually `variables.tf`).

### Minimal Declaration

```hcl
variable "region" {}
```

This declares a variable named `region` with no type constraint or default. Terraform will prompt you for a value at runtime if none is provided.

### Full Declaration Syntax

```hcl
variable "<NAME>" {
  type        = <TYPE>
  default     = <VALUE>
  description = "<DESCRIPTION>"
  sensitive   = <true|false>

  validation {
    condition     = <EXPRESSION>
    error_message = "<MESSAGE>"
  }
}
```

### Example

```hcl
variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "The EC2 instance type to deploy."
}
```

### Referencing a Variable

Use `var.<NAME>` anywhere inside your Terraform configuration:

```hcl
resource "aws_instance" "web" {
  instance_type = var.instance_type
  ami           = "ami-0c55b159cbfafe1f0"
}
```

---

## 3. Variable Types

Terraform's type system prevents configuration mistakes early. Types fall into two categories: **primitive** and **complex**.

### 3.1 Primitive Types

#### `string`

A sequence of Unicode characters.

```hcl
variable "environment" {
  type    = string
  default = "production"
}
```

#### `number`

An integer or floating-point number.

```hcl
variable "instance_count" {
  type    = number
  default = 2
}
```

#### `bool`

A boolean: either `true` or `false`.

```hcl
variable "enable_monitoring" {
  type    = bool
  default = true
}
```

---

### 3.2 Complex Types

#### `list(<TYPE>)`

An ordered sequence of values, all of the same type.

```hcl
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
```

Access elements by index (zero-based):

```hcl
# First availability zone
var.availability_zones[0]  # => "us-east-1a"
```

#### `set(<TYPE>)`

Like a list but **unordered** and contains **no duplicates**.

```hcl
variable "allowed_cidrs" {
  type    = set(string)
  default = ["10.0.0.0/8", "192.168.0.0/16"]
}
```

#### `map(<TYPE>)`

A collection of key-value pairs where all values share the same type.

```hcl
variable "tags" {
  type = map(string)
  default = {
    Team        = "platform"
    Environment = "staging"
    Owner       = "devops"
  }
}
```

Access values by key:

```hcl
var.tags["Environment"]  # => "staging"
```

#### `object({...})`

A structured collection with **named attributes** that can have **different types**.

```hcl
variable "server_config" {
  type = object({
    instance_type = string
    disk_size_gb  = number
    enable_ipv6   = bool
  })
  default = {
    instance_type = "t3.small"
    disk_size_gb  = 50
    enable_ipv6   = false
  }
}
```

Access attributes using dot notation:

```hcl
var.server_config.instance_type  # => "t3.small"
var.server_config.disk_size_gb   # => 50
```

#### `tuple([<TYPE>, ...])`

An ordered sequence where each element can be a **different type**. Unlike a list, the number of elements and types are fixed.

```hcl
variable "app_settings" {
  type    = tuple([string, number, bool])
  default = ["nginx", 80, true]
}

# Access by index
var.app_settings[0]  # => "nginx"
var.app_settings[1]  # => 80
```

#### `any`

Disables type checking. Terraform will infer the type at runtime. Use sparingly.

```hcl
variable "flexible_input" {
  type = any
}
```

---

## 4. Default Values

A `default` makes the variable optional — if no value is provided, Terraform uses the default.

```hcl
variable "port" {
  type    = number
  default = 8080
}
```

Without a default, the variable is **required** and Terraform will either prompt for it interactively or raise an error if not supplied.

```hcl
# Required variable — no default
variable "db_password" {
  type      = string
  sensitive = true
}
```

> **Tip:** Set `default = null` to make a variable optional while still allowing it to be omitted by callers.

```hcl
variable "extra_tags" {
  type    = map(string)
  default = null
}
```

---

## 5. Validation Rules

You can enforce constraints on variable values using `validation` blocks. If the `condition` evaluates to `false`, Terraform shows the `error_message`.

### Single Validation

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment."

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "environment must be one of: dev, staging, production."
  }
}
```

### Multiple Validations

```hcl
variable "instance_count" {
  type        = number
  description = "Number of instances to launch."

  validation {
    condition     = var.instance_count >= 1
    error_message = "instance_count must be at least 1."
  }

  validation {
    condition     = var.instance_count <= 20
    error_message = "instance_count must not exceed 20."
  }
}
```

### String Pattern Matching

```hcl
variable "bucket_name" {
  type        = string
  description = "S3 bucket name. Must be lowercase and use hyphens only."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.bucket_name))
    error_message = "bucket_name must contain only lowercase letters, numbers, and hyphens."
  }
}
```

### Common Validation Functions

| Function | Use Case |
|----------|----------|
| `contains(list, value)` | Check if value is in a list |
| `can(regex(pattern, str))` | Regex match |
| `length(var.x) > 0` | Non-empty check |
| `startswith(str, prefix)` | Prefix check |
| `endswith(str, suffix)` | Suffix check |

---

## 6. Sensitive Variables

Mark a variable as `sensitive = true` to prevent its value from being shown in logs, plan output, or state diffs.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}

variable "api_key" {
  type      = string
  sensitive = true
}
```

Terraform will display `(sensitive value)` instead of the actual value:

```
  + db_password = (sensitive value)
```

> **Important:** Sensitive values are still stored in the state file in plain text. Always use a **remote backend** (like Terraform Cloud or S3 with encryption) for sensitive configurations.

---

## 7. Assigning Variable Values

There are multiple ways to pass values to variables. They are applied in a specific precedence order (see [Section 10](#10-variable-precedence)).

### 7.1 Default Value (in variable block)

```hcl
variable "region" {
  default = "us-east-1"
}
```

### 7.2 `.tfvars` File

Create a file named `terraform.tfvars` or `*.auto.tfvars` — Terraform loads these automatically.

**`terraform.tfvars`:**
```hcl
region         = "us-west-2"
instance_count = 3
environment    = "staging"
tags = {
  Team = "backend"
  Env  = "staging"
}
```

**Custom `.tfvars` file (must be passed explicitly):**
```bash
terraform apply -var-file="prod.tfvars"
```

### 7.3 `-var` Command-Line Flag

```bash
terraform apply -var="region=eu-west-1" -var="instance_count=5"
```

### 7.4 Environment Variables

Prefix the variable name with `TF_VAR_`:

```bash
export TF_VAR_region="ap-southeast-1"
export TF_VAR_db_password="s3cr3t!"
terraform apply
```

### 7.5 Interactive Prompt

If no value is provided and there's no default, Terraform prompts you:

```
var.region
  Enter a value: us-east-1
```

---

## 8. Output Variables

Outputs expose values from your configuration — useful for displaying results or passing values between modules.

### Declaration

```hcl
output "instance_ip" {
  value       = aws_instance.web.public_ip
  description = "The public IP address of the web server."
}

output "db_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "The RDS database endpoint."
  sensitive   = true
}
```

### Viewing Outputs

```bash
# After apply, outputs are shown automatically
terraform apply

# View outputs at any time
terraform output
terraform output instance_ip
terraform output -json
```

### Using Outputs Between Modules

Parent module consuming a child module's output:

```hcl
module "network" {
  source = "./modules/network"
  region = var.region
}

# Reference child module output
resource "aws_instance" "app" {
  subnet_id = module.network.public_subnet_id
}
```

Child module (`./modules/network/outputs.tf`):
```hcl
output "public_subnet_id" {
  value = aws_subnet.public.id
}
```

---

## 9. Local Values

Locals let you compute and name intermediate expressions to avoid repetition.

### Declaring Locals

```hcl
locals {
  # Simple computed value
  full_name = "${var.project}-${var.environment}"

  # Conditional
  instance_type = var.environment == "production" ? "m5.large" : "t3.micro"

  # Merge maps
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}
```

### Referencing Locals

Use `local.<NAME>` (note: `local`, not `locals`):

```hcl
resource "aws_instance" "web" {
  instance_type = local.instance_type
  tags          = local.common_tags
}

resource "aws_s3_bucket" "data" {
  bucket = "${local.full_name}-data"
  tags   = local.common_tags
}
```

### When to Use Locals vs Variables

| Use | When |
|-----|------|
| `variable` | Value comes from outside (caller, user, CI/CD) |
| `local` | Value is derived or computed inside the module |

---

## 10. Variable Precedence

When the same variable is set in multiple places, Terraform uses this order (highest to lowest):

```
1. -var flag                     ← HIGHEST PRIORITY
2. -var-file flag
3. *.auto.tfvars files           (loaded alphabetically)
4. terraform.tfvars.json
5. terraform.tfvars
6. TF_VAR_* environment variables
7. Default value in variable block ← LOWEST PRIORITY
```

> **Example:** If `region = "us-east-1"` is set in `terraform.tfvars` AND you run `terraform apply -var="region=eu-west-1"`, the `-var` flag wins and `eu-west-1` is used.

---

## 11. Complex Types in Practice

### 11.1 List of Objects

```hcl
variable "subnets" {
  type = list(object({
    name       = string
    cidr_block = string
    public     = bool
  }))
  default = [
    { name = "public-1",  cidr_block = "10.0.1.0/24", public = true  },
    { name = "private-1", cidr_block = "10.0.2.0/24", public = false },
  ]
}
```

Iterate with `for_each` or `for`:

```hcl
resource "aws_subnet" "this" {
  for_each = { for s in var.subnets : s.name => s }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr_block
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = each.key
  }
}
```

### 11.2 Map of Objects

```hcl
variable "services" {
  type = map(object({
    port     = number
    replicas = number
  }))
  default = {
    api     = { port = 8080, replicas = 3 }
    worker  = { port = 9090, replicas = 2 }
    gateway = { port = 80,   replicas = 1 }
  }
}
```

```hcl
resource "aws_ecs_service" "this" {
  for_each      = var.services
  name          = each.key
  desired_count = each.value.replicas
  # ... more config
}
```

### 11.3 Using `for` Expressions with Variables

```hcl
variable "usernames" {
  type    = list(string)
  default = ["alice", "bob", "carol"]
}

locals {
  # Create a map from username to email
  user_emails = { for u in var.usernames : u => "${u}@example.com" }
}

# local.user_emails => {
#   alice = "alice@example.com"
#   bob   = "bob@example.com"
#   carol = "carol@example.com"
# }
```

---

## 12. Practice Exercises

Work through these exercises in order. Each one builds on the previous.

---

### Exercise 1 — Basic Variable Declaration

**Goal:** Create a variable and use it in a resource.

**Task:**
1. Create `variables.tf` with a `string` variable called `bucket_name` with no default.
2. Create `main.tf` that creates an `aws_s3_bucket` using `var.bucket_name`.
3. Create `terraform.tfvars` and set `bucket_name = "my-practice-bucket-12345"`.
4. Run `terraform plan` and verify the bucket name appears correctly.

**Expected `variables.tf`:**
```hcl
variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}
```

**Expected `terraform.tfvars`:**
```hcl
bucket_name = "my-practice-bucket-12345"
```

---

### Exercise 2 — Multiple Variable Types

**Goal:** Use `string`, `number`, and `bool` variables together.

**Task:**
1. Declare three variables:
   - `app_name` (string, default: `"myapp"`)
   - `replica_count` (number, default: `2`)
   - `enable_https` (bool, default: `true`)
2. Create a `locals` block that builds a `config_summary` string using all three.
3. Create an output that prints `config_summary`.

**Solution:**
```hcl
# variables.tf
variable "app_name" {
  type    = string
  default = "myapp"
}

variable "replica_count" {
  type    = number
  default = 2
}

variable "enable_https" {
  type    = bool
  default = true
}

# locals.tf
locals {
  config_summary = "${var.app_name}: ${var.replica_count} replicas, HTTPS=${var.enable_https}"
}

# outputs.tf
output "config_summary" {
  value = local.config_summary
}
```

---

### Exercise 3 — Validation

**Goal:** Add validation rules to prevent invalid input.

**Task:**
1. Create a variable `environment` of type `string`.
2. Add a validation that only allows `"dev"`, `"staging"`, or `"production"`.
3. Test it by passing `"test"` as a value. What error do you see?
4. Add a second variable `replica_count` with a validation that enforces the value is between 1 and 10.

**Solution:**
```hcl
variable "environment" {
  type        = string
  description = "Deployment environment."

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Must be one of: dev, staging, production."
  }
}

variable "replica_count" {
  type        = number
  description = "Number of replicas (1–10)."

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 10
    error_message = "replica_count must be between 1 and 10."
  }
}
```

---

### Exercise 4 — Map Variable and Tags

**Goal:** Use a `map(string)` variable for resource tags.

**Task:**
1. Declare a `map(string)` variable `tags` with default values for `Team` and `Project`.
2. In `locals`, merge `var.tags` with a computed `Environment` tag from another variable.
3. Apply the merged tags to a resource.

**Solution:**
```hcl
variable "tags" {
  type = map(string)
  default = {
    Team    = "platform"
    Project = "infra"
  }
}

variable "environment" {
  type    = string
  default = "dev"
}

locals {
  all_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = local.all_tags
}
```

---

### Exercise 5 — List of Objects and `for_each`

**Goal:** Use a `list(object(...))` variable to create multiple resources dynamically.

**Task:**
1. Declare a variable `users` as a `list(object({ name = string, admin = bool }))`.
2. Set defaults for at least 3 users.
3. Use `for_each` to create an `aws_iam_user` for each user.
4. Add an output that lists all user names.

**Solution:**
```hcl
variable "users" {
  type = list(object({
    name  = string
    admin = bool
  }))
  default = [
    { name = "alice", admin = true  },
    { name = "bob",   admin = false },
    { name = "carol", admin = false },
  ]
}

resource "aws_iam_user" "this" {
  for_each = { for u in var.users : u.name => u }
  name     = each.key
  tags = {
    Admin = tostring(each.value.admin)
  }
}

output "user_names" {
  value = [for u in var.users : u.name]
}
```

---

### Exercise 6 — Sensitive Variables and Outputs

**Goal:** Handle secrets safely.

**Task:**
1. Declare a `db_password` variable as `sensitive = true` with no default.
2. Create a `locals` block that builds a connection string using `db_password` and a `db_host` variable.
3. Create an output `connection_string` and mark it `sensitive = true`.
4. Run `terraform plan` and observe how the sensitive value is masked.

**Solution:**
```hcl
variable "db_host" {
  type    = string
  default = "db.example.com"
}

variable "db_password" {
  type      = string
  sensitive = true
}

locals {
  connection_string = "postgresql://admin:${var.db_password}@${var.db_host}:5432/appdb"
}

output "connection_string" {
  value     = local.connection_string
  sensitive = true
}
```

---

### Exercise 7 — Variable Precedence Challenge

**Goal:** Understand how Terraform resolves conflicting variable sources.

**Setup:**
```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}
```

**Task:**
1. Set `region = "eu-west-1"` in `terraform.tfvars`.
2. Set `export TF_VAR_region="ap-southeast-1"` in your shell.
3. Run `terraform plan` — which region wins?
4. Now run `terraform plan -var="region=ca-central-1"` — which wins now?
5. Document the full precedence order from your observations.

**Expected answers:**
- Step 3: `terraform.tfvars` wins over env var → `eu-west-1`
- Step 4: `-var` flag wins over everything → `ca-central-1`

---

## 13. Cheat Sheet

```
DECLARE A VARIABLE
──────────────────
variable "name" {
  type        = string|number|bool|list|map|set|object|tuple|any
  default     = <value>
  description = "..."
  sensitive   = true|false
  validation { condition = ... ; error_message = "..." }
}

REFERENCE A VARIABLE
────────────────────
var.name

DECLARE A LOCAL
───────────────
locals {
  computed = "${var.a}-${var.b}"
}
local.computed

DECLARE AN OUTPUT
─────────────────
output "name" {
  value       = <expression>
  description = "..."
  sensitive   = true|false
}

SET VARIABLE VALUES
───────────────────
1. terraform apply -var="key=value"              # Highest priority
2. terraform apply -var-file="custom.tfvars"
3. *.auto.tfvars                                 # Auto-loaded
4. terraform.tfvars.json                         # Auto-loaded
5. terraform.tfvars                              # Auto-loaded
6. export TF_VAR_key="value"
7. default = "value" in variable block           # Lowest priority

COMMON TYPE SYNTAX
──────────────────
string          number          bool
list(string)    list(number)    list(bool)
map(string)     map(number)     set(string)
object({ a = string, b = number })
tuple([string, number, bool])
any

USEFUL FUNCTIONS IN VALIDATIONS
────────────────────────────────
contains(list, val)             # val in list?
can(regex("^[a-z]+$", var.x))  # regex match
length(var.x) >= 1             # non-empty
startswith(var.x, "prefix")
endswith(var.x, "suffix")

ITERATE COMPLEX VARIABLES
──────────────────────────
# List → for_each
for_each = { for item in var.list : item.key => item }

# Map → for_each
for_each = var.map

# for expression
[for x in var.list : upper(x)]
{ for k, v in var.map : k => "${v}-suffix" }
```

---

> **Next steps:** Once you're comfortable with variables, explore **Terraform modules** to learn how variables flow between reusable module components, and **Terraform workspaces** for managing variable values across environments.