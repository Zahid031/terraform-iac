###############################################################################
# Module: security-groups
# Creates all SGs for the rideshare platform.
# Receives vpc_id + vpc_cidr as variables — never reads remote state itself.
###############################################################################

# ── EKS Cluster SG (control plane <-> nodes) ─────────────────────────────────
resource "aws_security_group" "eks_cluster" {
  name        = "${var.name}-sg-eks-cluster"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}-sg-eks-cluster" })
}

resource "aws_security_group_rule" "cluster_ingress_nodes" {
  security_group_id        = aws_security_group.eks_cluster.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_nodes.id
  description              = "Nodes to API server"
}

resource "aws_security_group_rule" "cluster_egress_all" {
  security_group_id = aws_security_group.eks_cluster.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ── EKS Nodes SG ─────────────────────────────────────────────────────────────
resource "aws_security_group" "eks_nodes" {
  name        = "${var.name}-sg-eks-nodes"
  description = "EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name                                        = "${var.name}-sg-eks-nodes"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "karpenter.sh/discovery"                    = var.cluster_name
  })
}

resource "aws_security_group_rule" "nodes_ingress_self" {
  security_group_id        = aws_security_group.eks_nodes.id
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.eks_nodes.id
  description              = "Node-to-node all traffic"
}

resource "aws_security_group_rule" "nodes_ingress_cluster_ephemeral" {
  security_group_id        = aws_security_group.eks_nodes.id
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  description              = "Control plane to nodes (kubelet/pods)"
}

resource "aws_security_group_rule" "nodes_ingress_cluster_443" {
  security_group_id        = aws_security_group.eks_nodes.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster.id
  description              = "Control plane webhooks"
}

resource "aws_security_group_rule" "nodes_egress_all" {
  security_group_id = aws_security_group.eks_nodes.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ── ALB SG ───────────────────────────────────────────────────────────────────
resource "aws_security_group" "alb" {
  name        = "${var.name}-sg-alb"
  description = "External ALB — HTTP/HTTPS from internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-sg-alb" })
}

# ── Data Plane SG (Postgres, Redis, Kafka, ScyllaDB) ─────────────────────────
resource "aws_security_group" "data_plane" {
  name        = "${var.name}-sg-data-plane"
  description = "Data services — reachable from EKS nodes only"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
    description     = "Postgres"
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
    description     = "Redis"
  }

  ingress {
    from_port       = 9092
    to_port         = 9092
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
    description     = "Kafka plaintext"
  }

  ingress {
    from_port       = 9093
    to_port         = 9093
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
    description     = "Kafka TLS"
  }

  ingress {
    from_port       = 9042
    to_port         = 9042
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
    description     = "ScyllaDB CQL"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-sg-data-plane" })
}

# ── Bastion SG ───────────────────────────────────────────────────────────────
resource "aws_security_group" "bastion" {
  name        = "${var.name}-sg-bastion"
  description = "Bastion — SSH from allowed CIDRs only (SSM preferred)"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.bastion_allowed_cidrs
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
      description = "SSH from ${ingress.value}"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-sg-bastion" })
}
