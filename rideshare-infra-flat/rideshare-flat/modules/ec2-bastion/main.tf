###############################################################################
# Module: ec2-bastion
# Private bastion accessed via SSM Session Manager — no public IP, no key pair.
# Placed in private-app subnet; SSM agent handles all access.
###############################################################################

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  iam_instance_profile   = aws_iam_instance_profile.bastion.name

  # No key_name — SSM Session Manager is the only access method
  # Uncomment below only if SSH fallback is required:
  # key_name = var.key_name

  metadata_options {
    http_tokens                 = "required"   # enforce IMDSv2
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    dnf update -y
    dnf install -y amazon-ssm-agent aws-cli

    # kubectl matching cluster version
    curl -LO "https://dl.k8s.io/release/v${var.kubectl_version}/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/

    systemctl enable --now amazon-ssm-agent
  USERDATA
  )

  tags = merge(var.tags, { Name = "${var.name}-bastion" })
}

# ── Bastion IAM Role ──────────────────────────────────────────────────────────
resource "aws_iam_role" "bastion" {
  name = "${var.name}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy" "eks_access" {
  name = "eks-describe"
  role = aws_iam_role.bastion.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["eks:DescribeCluster", "eks:ListClusters"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.name}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
  tags = var.tags
}
