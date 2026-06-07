###############################################################################
# VPC
###############################################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "${var.name}-vpc"
  })
}

###############################################################################
# Internet Gateway
###############################################################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-igw"
  })
}

###############################################################################
# Public Subnets
###############################################################################
resource "aws_subnet" "public" {
  for_each = { for i, az in var.availability_zones : az => {
    az   = az
    cidr = var.public_subnet_cidrs[i]
  }}

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                     = "${var.name}-public-${each.value.az}"
    Tier                     = "public"
    "kubernetes.io/role/elb" = "1"
  })
}

###############################################################################
# Private App Subnets
###############################################################################
resource "aws_subnet" "private_app" {
  for_each = { for i, az in var.availability_zones : az => {
    az   = az
    cidr = var.private_app_subnet_cidrs[i]
  }}

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name                                        = "${var.name}-private-app-${each.value.az}"
    Tier                                        = "private-app"
    "kubernetes.io/role/internal-elb"           = "1"
    "karpenter.sh/discovery"                    = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

###############################################################################
# Private Data Subnets
###############################################################################
resource "aws_subnet" "private_data" {
  for_each = { for i, az in var.availability_zones : az => {
    az   = az
    cidr = var.private_data_subnet_cidrs[i]
  }}

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(var.tags, {
    Name = "${var.name}-private-data-${each.value.az}"
    Tier = "private-data"
  })
}

###############################################################################
# Elastic IPs + NAT Gateways
# single_nat_gateway = true  → 1 NAT in first AZ (dev/staging cost saving)
# single_nat_gateway = false → 1 NAT per AZ (prod HA)
###############################################################################
locals {
  nat_az_keys = var.enable_nat_gateway ? (
    var.single_nat_gateway
      ? [var.availability_zones[0]]
      : var.availability_zones
  ) : []
}

resource "aws_eip" "nat" {
  for_each = toset(local.nat_az_keys)

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name}-eip-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = toset(local.nat_az_keys)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(var.tags, {
    Name = "${var.name}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

###############################################################################
# Route Table — Public (1 shared across all AZs)
###############################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name}-rt-public"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

###############################################################################
# Route Tables — Private (one per AZ)
# App + Data subnets both associate to their AZ's private RT.
# When single_nat_gateway = true, all private RTs point to the same NAT.
###############################################################################
# resource "aws_route_table" "private" {
#   for_each = toset(var.availability_zones)

#   vpc_id = aws_vpc.this.id

#   dynamic "route" {
#     for_each = var.enable_nat_gateway ? [1] : []
#     content {
#       cidr_block     = "0.0.0.0/0"
#       nat_gateway_id = var.single_nat_gateway
#         ? aws_nat_gateway.this[var.availability_zones[0]].id
#         : aws_nat_gateway.this[each.key].id
#     }
#   }

#   tags = merge(var.tags, {
#     Name = "${var.name}-rt-private-${each.key}"
#   })
# }
resource "aws_route_table" "private" {
  for_each = toset(var.availability_zones)

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? (
        aws_nat_gateway.this[var.availability_zones[0]].id
      ) : (
        aws_nat_gateway.this[each.key].id
      )
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-rt-private-${each.key}"
  })
}
resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "private_data" {
  for_each = aws_subnet.private_data

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

###############################################################################
# VPC Gateway Endpoints — S3 + DynamoDB (free, no NAT traffic)
###############################################################################
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_s3_endpoint ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    [for rt in aws_route_table.private : rt.id]
  )

  tags = merge(var.tags, { Name = "${var.name}-vpce-s3" })
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = var.enable_dynamodb_endpoint ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = concat(
    [aws_route_table.public.id],
    [for rt in aws_route_table.private : rt.id]
  )

  tags = merge(var.tags, { Name = "${var.name}-vpce-dynamodb" })
}

###############################################################################
# VPC Interface Endpoints — ECR, SSM, STS, Logs (keeps EKS traffic off NAT)
# Security group shared across all interface endpoints
###############################################################################
locals {
  interface_endpoints = merge(
    var.enable_ecr_endpoints ? {
      "ecr.api" = "com.amazonaws.${var.region}.ecr.api"
      "ecr.dkr" = "com.amazonaws.${var.region}.ecr.dkr"
    } : {},
    var.enable_sts_endpoint ? {
      "sts" = "com.amazonaws.${var.region}.sts"
    } : {},
    var.enable_ssm_endpoints ? {
      "ssm"         = "com.amazonaws.${var.region}.ssm"
      "ssmmessages" = "com.amazonaws.${var.region}.ssmmessages"
      "ec2messages" = "com.amazonaws.${var.region}.ec2messages"
    } : {},
    var.enable_cloudwatch_endpoint ? {
      "logs" = "com.amazonaws.${var.region}.logs"
    } : {}
  )

  create_endpoint_sg = length(local.interface_endpoints) > 0
}

resource "aws_security_group" "vpc_endpoints" {
  count = local.create_endpoint_sg ? 1 : 0

  name        = "${var.name}-sg-vpce"
  description = "HTTPS from VPC to interface endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-sg-vpce" })
}

resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.this.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.private_app : s.id]
  security_group_ids  = [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = true

  tags = merge(var.tags, { Name = "${var.name}-vpce-${each.key}" })
}

###############################################################################
# VPC Flow Logs
###############################################################################
resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/${var.name}/flow-logs"
  retention_in_days = var.flow_logs_retention_days

  tags = var.tags
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name = "${var.name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  role       = aws_iam_role.flow_logs[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id          = aws_vpc.this.id
  traffic_type    = "ALL"
  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn

  tags = merge(var.tags, { Name = "${var.name}-flow-log" })
}
