# modules/nat-gateway/main.tf

locals {
  nat_count = var.create_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.public_subnet_ids)) : 0
}

resource "aws_eip" "nat" {
  count  = local.nat_count
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "this" {
  count = local.nat_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.public_subnet_ids[count.index]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
  })

  depends_on = [aws_eip.nat]
}

# Add NAT route to each private route table
resource "aws_route" "private_nat" {
  count = var.create_nat_gateway ? length(var.private_route_table_ids) : 0

  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = "0.0.0.0/0"
  # single NAT → all private subnets use index 0; multi → one-to-one
  nat_gateway_id = aws_nat_gateway.this[var.single_nat_gateway ? 0 : count.index].id
}
