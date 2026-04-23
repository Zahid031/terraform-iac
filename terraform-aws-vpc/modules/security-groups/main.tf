# modules/security-groups/main.tf

# Default SG — tighten the AWS default (deny all by default)
resource "aws_default_security_group" "default" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-default-sg"
  })
}

# Public Security Group — for load balancers and bastion hosts
resource "aws_security_group" "public" {
  name        = "${var.project_name}-${var.environment}-public-sg"
  description = "Allow inbound HTTP/HTTPS from internet"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-public-sg"
  })
}

# Private Security Group — for app servers and databases
resource "aws_security_group" "private" {
  name        = "${var.project_name}-${var.environment}-private-sg"
  description = "Allow inbound from within the VPC only"
  vpc_id      = var.vpc_id

  ingress {
    description = "All traffic from within VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-private-sg"
  })
}
